import { Page, expect } from '@playwright/test';
import { APP_URL, SB_URL, SB_ANON_KEY } from '../playwright.config';

/**
 * Conta E2E dedicada. Em instancias Clerk dev, qualquer email terminado em
 * "+clerk_test@example.com" verifica com o codigo fixo 424242 — permite
 * sign-in programatico sem storageState nem login manual.
 * O utilizador tem de existir: criar uma vez via UI da app, ou desligar
 * "Bot sign-up protection" no Clerk dashboard (dev) para auto-provisionar.
 */
/**
 * Credenciais da conta E2E via env (nunca commitar senhas):
 *   E2E_EMAIL / E2E_PASSWORD  — conta com password
 *   (sem env)                 — conta clerk_test com email_code 424242,
 *                               desde que exista (criar uma vez via UI).
 */
export const TEST_EMAIL =
  process.env.E2E_EMAIL ?? 'petcare.e2e+clerk_test@example.com';
export const TEST_PASSWORD = process.env.E2E_PASSWORD;
export const TEST_CODE = '424242';

/** Pagina nova num contexto limpo (a sessao e criada por openApp). */
export async function newSessionPage(
  browser: import('@playwright/test').Browser,
) {
  const context = await browser.newContext();
  const page = await context.newPage();
  return { context, page };
}

/**
 * Flutter Web desenha em canvas — os elementos DOM so existem depois de
 * ativar a arvore de semantica (botao invisivel "Enable accessibility").
 * A arvore usa <flt-semantics>: botoes tem role="button" + texto no conteudo;
 * textos estaticos ficam em <span> filhos; text fields ganham aria-label.
 */
export async function waitForApp(page: Page, timeout = 90_000) {
  // O placeholder so existe se a semantica ainda nao estiver ativa —
  // o Flutter pode auto-ativa-la (a11y detection / estado persistido).
  await page.waitForSelector(
    'flt-semantics-placeholder, flt-semantics',
    { timeout },
  );
}

export async function enableSemantics(page: Page) {
  // Se a arvore ja existe, nada a fazer.
  if ((await page.locator('flt-semantics').count()) > 0) return;
  // Clique JS direto: o placeholder e removido do DOM depois de ativar.
  const clicked = await page.evaluate(() => {
    const ph = document.querySelector('flt-semantics-placeholder');
    if (!ph) return false;
    (ph as HTMLElement).click();
    return true;
  });
  if (!clicked) {
    // Race: a semantica pode ter auto-ativado entre o wait e o evaluate.
    if ((await page.locator('flt-semantics').count()) > 0) return;
    throw new Error('semantica nao ativou — app nao arrancou');
  }
  await page.waitForSelector('flt-semantics', { timeout: 30_000 });
}

/**
 * Sign-in programatico via email_code clerk_test dentro da pagina.
 * Cria uma sessao real no Clerk (sem CAPTCHA — sign-in nao tem captcha).
 * Se o utilizador nao existir, tenta sign-up (so funciona com bot
 * protection desligada no Clerk dev).
 */
async function signInProgrammatic(page: Page) {
  const result = await page.evaluate(
    async ({ email, code }) => {
      const C = (window as any).Clerk;
      const password: string | null = (window as any).__E2E_PASSWORD ?? null;
      try {
        const si = await C.client.signIn.create({ identifier: email });
        if (password) {
          const att = await si.attemptFirstFactor({
            strategy: 'password',
            password,
          });
          if (att.status === 'complete') {
            return { session: att.createdSessionId };
          }
          return { err: `signIn(password) status ${att.status}` };
        }
        const factor = si.supportedFirstFactors?.find(
          (f: any) => f.strategy === 'email_code',
        );
        if (!factor) {
          return {
            err: 'email_code nao suportado: ' +
              JSON.stringify(si.supportedFirstFactors?.map((f: any) => f.strategy)),
          };
        }
        await si.prepareFirstFactor({
          strategy: 'email_code',
          emailAddressId: factor.emailAddressId,
        });
        const att = await si.attemptFirstFactor({
          strategy: 'email_code',
          code,
        });
        if (att.status === 'complete') return { session: att.createdSessionId };
        return { err: `signIn status ${att.status}` };
      } catch (e: any) {
        const notFound = e?.errors?.some(
          (x: any) => x.code === 'form_identifier_not_found',
        );
        if (!notFound) {
          return {
            err: JSON.stringify(e?.errors ?? String(e)).slice(0, 400),
          };
        }
        // Utilizador nao existe — tenta sign-up (requer bot protection off).
        try {
          const su = await C.client.signUp.create({ emailAddress: email });
          await su.prepareEmailAddressVerification({ strategy: 'email_code' });
          const att = await su.attemptEmailAddressVerification({ code });
          if (att.status === 'complete') return { session: att.createdSessionId };
          return { err: `signUp status ${att.status}` };
        } catch (e2: any) {
          return { err: `signUp: ${String(e2?.errors ?? e2).slice(0, 300)}` };
        }
      }
    },
    { email: TEST_EMAIL, code: TEST_CODE },
  );
  if (result.err) {
    throw new Error(
      `Login E2E falhou: ${result.err}. Cria a conta ${TEST_EMAIL} ` +
        'uma vez via UI da app (codigo 424242) ou desliga "Bot sign-up ' +
        'protection" no Clerk dashboard.',
    );
  }
  await page.evaluate(async (sid: string) => {
    await (window as any).Clerk.setActive({ session: sid });
  }, result.session as string);
}

/**
 * Abre a app e espera ficar autenticado na lista de pets.
 * Deep links nao funcionam: o redirect do router corre antes do Clerk
 * carregar e colapsa tudo para /pets (ou /onboarding). Por isso a
 * navegacao para outros ecraos e feita pela UI nos testes.
 */
export async function openApp(page: Page) {
  await page.addInitScript((pw: string | null) => {
    try {
      // shared_preferences_web guarda chaves com prefixo flutter.
      localStorage.setItem('flutter.onboarding_seen', 'true');
      if (pw) (window as any).__E2E_PASSWORD = pw;
    } catch {}
  }, TEST_PASSWORD ?? null);
  await page.goto(`${APP_URL}/pets`, { waitUntil: 'domcontentloaded' });
  await waitForApp(page);
  await enableSemantics(page);
  // Espera o ClerkJS (bridge) inicializar.
  await page.waitForFunction(
    () => (window as any).Clerk?.client != null,
    { timeout: 60_000 },
  );
  if (!(await page.evaluate(() => (window as any).Clerk?.user?.id != null))) {
    await signInProgrammatic(page);
    // Reload: a app arranca ja autenticada e o router estabiliza em /pets.
    await page.reload({ waitUntil: 'domcontentloaded' });
    await waitForApp(page);
    await enableSemantics(page);
  }
  await page.waitForFunction(
    () => (window as any).Clerk?.user?.id != null,
    { timeout: 60_000 },
  );
  await expect(nodeWithLabel(page, 'Meus pets')).toBeVisible({
    timeout: 30_000,
  });
}

function cssEscape(s: string) {
  return s.replace(/[\\"]/g, '\\$&');
}

/**
 * Nó de semantica cujo conteudo/aria-label contem o texto.
 * Devolve o mais especifico (.last() = descendente mais profundo).
 */
export function nodeWithLabel(page: Page, label: string) {
  const esc = cssEscape(label);
  return page
    .locator(
      `flt-semantics[aria-label*="${esc}"], flt-semantics:has-text("${esc}")`,
    )
    .last();
}

/** Clica num botao Flutter pelo nome acessivel (exact primeiro, parcial depois). */
export async function tapButton(page: Page, name: string | RegExp) {
  const exact =
    typeof name === 'string'
      ? page.getByRole('button', { name, exact: true })
      : page.getByRole('button', { name });
  if ((await exact.count()) > 0) {
    await exact.first().click();
    return;
  }
  // Fallback: no com texto correspondente (cards, list tiles tappable)
  if (typeof name === 'string') {
    await nodeWithLabel(page, name).click();
  } else {
    await page.locator('flt-semantics').filter({ hasText: name }).last().click();
  }
}

/**
 * Preenche um TextFormField Flutter. Ao focar, a engine injeta um
 * <input>/<textarea> real em <flt-text-editing-host> que aceita fill().
 */
export async function fillField(page: Page, label: string, value: string) {
  // A engine mantem um <input aria-label="..."> dentro de cada no de campo.
  // O aria-label conserva a labelText mesmo quando o campo tem valor —
  // ao contrario do nome acessivel do no, que passa a ser o valor.
  const esc = cssEscape(label);
  const input = page.locator(
    `flt-semantics input[data-semantics-role="text-field"][aria-label*="${esc}"]`,
  );
  if ((await input.count()) > 0) {
    await input.last().fill(value);
    await page.waitForTimeout(150);
    return;
  }
  // Fallback: campo sem input injetado (ex.: dentro de bottom sheet)
  const box = page.getByRole('textbox', { name: label }).last();
  if ((await box.count()) > 0) {
    await box.click();
  } else {
    await nodeWithLabel(page, label).click();
  }
  await page.waitForTimeout(400);
  await page.keyboard.type(value);
  await page.waitForTimeout(150);
}

/**
 * Abre o detalhe de um pet na lista com retry — a lista pode reconstruir
 * (stream realtime) entre a resolucao do locator e o clique.
 */
export async function openPet(page: Page, petName: string, marker = 'Cuidadores') {
  const rx = new RegExp(petName.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'));
  const card = page.getByRole('button', { name: rx }).first();
  for (let attempt = 0; attempt < 3; attempt++) {
    // A stream realtime pode demorar a emitir — espera o card aparecer.
    await card.waitFor({ state: 'visible', timeout: 30_000 });
    await card.click();
    try {
      await expect(tapTarget(page, marker)).toBeVisible({ timeout: 10_000 });
      return;
    } catch {
      await page.waitForTimeout(1000);
    }
  }
  throw new Error(`Nao abriu o detalhe do pet ${petName}`);
}

/** Locator para um botao/no tappable (usado por tapButton e openPet). */
export function tapTarget(page: Page, name: string) {
  return page.locator(
    `flt-semantics[role="button"]:has-text("${cssEscape(name)}"), ` +
      `flt-semantics[flt-tappable]:has-text("${cssEscape(name)}")`,
  );
}

/**
 * Toca e espera pelo destino com retry — em transicoes de rota a arvore de
 * semantica e reconstruida e um clique num no stale e um no-op silencioso
 * (falha tipica em CI mais lento).
 */
export async function tapAndWait(
  page: Page,
  tap: string,
  marker: { heading?: string; text?: string },
  retries = 3,
) {
  const target = marker.heading
    ? page.getByRole('heading', { name: marker.heading })
    : nodeWithLabel(page, marker.text!);
  for (let i = 0; i < retries; i++) {
    await tapButton(page, tap);
    try {
      await expect(target).toBeVisible({ timeout: 12_000 });
      return;
    } catch {}
  }
  throw new Error(`tap '${tap}' nao chegou a ${JSON.stringify(marker)}`);
}

/** Obtem o JWT do Clerk (template supabase) dentro da pagina autenticada. */
export async function supabaseJwt(page: Page): Promise<string> {
  const token = await page.evaluate(async () => {
    const clerk = (window as any).Clerk;
    if (!clerk?.session) return null;
    try {
      return await clerk.session.getToken({ template: 'supabase' });
    } catch {
      return await clerk.session.getToken();
    }
  });
  if (!token) throw new Error('Sem sessao Clerk na pagina');
  return token as string;
}

/** Chamada REST ao Supabase com o JWT do utilizador autenticado (respeita RLS). */
export async function sbRest(
  page: Page,
  method: string,
  table: string,
  query: string,
  body?: unknown,
) {
  const jwt = await supabaseJwt(page);
  const res = await page.request.fetch(`${SB_URL}/rest/v1/${table}?${query}`, {
    method,
    headers: {
      apikey: SB_ANON_KEY,
      Authorization: `Bearer ${jwt}`,
      'Content-Type': 'application/json',
      Prefer: 'return=representation',
    },
    data: body,
  });
  if (!res.ok()) {
    throw new Error(`Supabase ${method} ${table}: ${res.status()} ${await res.text()}`);
  }
  return res.json();
}

export async function clerkUserId(page: Page): Promise<string> {
  const id = await page.evaluate(() => (window as any).Clerk?.user?.id ?? null);
  if (!id) throw new Error('Sem user Clerk na pagina');
  return id as string;
}

/** Cria um pet diretamente via REST (setup de testes). */
export async function createPetViaApi(page: Page, name: string) {
  const ownerId = await clerkUserId(page);
  const rows = await sbRest(page, 'POST', 'pets', '', {
    owner_id: ownerId,
    name,
    species: 'dog',
  });
  return rows[0].id as string;
}

/**
 * Apaga os pets de teste desta spec (cascade limpa medications, dose_logs,
 * caregivers). O prefixo isola a limpeza entre specs em paralelo — apagar
 * todos os "E2E" destruiria os pets dos outros workers.
 */
export async function cleanupTestPets(page: Page, prefix: string) {
  await sbRest(page, 'DELETE', 'pets', `name=like.${prefix}*`);
}

/** PNG 1x1 para upload de foto em testes. */
export const PNG_1PX = Buffer.from(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  'base64',
);
