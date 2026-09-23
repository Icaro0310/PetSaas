import { Page, expect } from '@playwright/test';
import { APP_URL, SB_URL, SB_ANON_KEY } from '../playwright.config';
import * as fs from 'fs';
import * as path from 'path';

export const AUTH_FILE = path.join(__dirname, '..', '.auth', 'session.json');

export function hasSession(): boolean {
  return fs.existsSync(AUTH_FILE);
}

/**
 * Flutter Web desenha em canvas — os elementos DOM so existem depois de
 * ativar a arvore de semantica (botao invisivel "Enable accessibility").
 * A arvore usa <flt-semantics>: botoes tem role="button" + texto no conteudo;
 * textos estaticos ficam em <span> filhos; text fields ganham aria-label.
 */
export async function waitForApp(page: Page, timeout = 90_000) {
  await page.waitForSelector('flt-semantics-placeholder', { timeout });
}

export async function enableSemantics(page: Page) {
  // Clique JS direto: o placeholder e removido do DOM depois de ativar.
  const clicked = await page.evaluate(() => {
    const ph = document.querySelector('flt-semantics-placeholder');
    if (!ph) return false;
    (ph as HTMLElement).click();
    return true;
  });
  if (!clicked) {
    throw new Error('flt-semantics-placeholder nao encontrado — app nao arrancou');
  }
  await page.waitForSelector('flt-semantics', { timeout: 30_000 });
}

export async function openApp(page: Page, route = '/pets') {
  // Deep link: GitHub Pages devolve 404.html que contem o fallback da app.
  await page.goto(`${APP_URL}${route}`, { waitUntil: 'domcontentloaded' });
  await waitForApp(page);
  await enableSemantics(page);
}

function cssEscape(s: string) {
  return s.replace(/"/g, '\\"');
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
  await nodeWithLabel(page, label).click();
  await page.waitForTimeout(400);
  const input = page
    .locator(
      'flt-text-editing-host input, flt-text-editing-host textarea, ' +
        'flt-semantics input, flt-semantics textarea',
    )
    .last();
  if ((await input.count()) > 0) {
    await input.fill(value);
    await input.dispatchEvent('input');
  } else {
    await page.keyboard.type(value);
  }
  await page.waitForTimeout(150);
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

/** Apaga todos os pets de teste (cascade limpa medications, dose_logs, caregivers). */
export async function cleanupTestPets(page: Page) {
  await sbRest(page, 'DELETE', 'pets', 'name=like.*E2E*');
}

/** PNG 1x1 para upload de foto em testes. */
export const PNG_1PX = Buffer.from(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  'base64',
);
