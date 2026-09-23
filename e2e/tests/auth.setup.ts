import { test as setup, chromium } from '@playwright/test';
import * as fs from 'fs';
import * as path from 'path';
import { APP_URL } from '../playwright.config';
import { AUTH_FILE } from '../helpers/app';

const FAPI = 'https://climbing-burro-4910.clerk.accounts.dev';

/**
 * Captura a sessao Clerk para os testes autenticados da app Flutter.
 *
 * Caminho 1 (CI/headless): CLERK_SECRET_KEY + E2E_EMAIL + E2E_PASSWORD
 *   -> testing token do Clerk + sign_in.create programatico (sem CAPTCHA).
 *
 * Caminho 2 (local): abre um browser visivel, o utilizador faz login a mao
 *   (resolve o CAPTCHA humanamente) e a sessao e guardada em .auth/session.json.
 *   A sessao Clerk dura ~7 dias; repete `npm run auth` quando expirar.
 */
setup('capturar sessao Clerk', async () => {
  fs.mkdirSync(path.dirname(AUTH_FILE), { recursive: true });

  const sk = process.env.CLERK_SECRET_KEY;
  const email = process.env.E2E_EMAIL;
  const password = process.env.E2E_PASSWORD;

  const browser = await chromium.launch({ headless: !sk ? false : true });
  const context = await browser.newContext();
  const page = await context.newPage();

  if (sk && email && password) {
    // --- Caminho 1: testing token ---
    const res = await fetch(`${FAPI}/v1/testing_tokens`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${sk}` },
    });
    if (!res.ok()) {
      throw new Error(`testing_token falhou: ${res.status} ${await res.text()}`);
    }
    const { token } = (await res.json()) as { token: string };
    // Anexa o testing token a todos os pedidos FAPI (padrao @clerk/testing).
    await context.route(/clerk\.accounts\.dev/, async (route) => {
      const url = new URL(route.request().url());
      url.searchParams.set('__clerk_testing_token', token);
      await route.continue({ url: url.toString() });
    });
    await page.goto(`${APP_URL}/login`);
    await page.waitForFunction(() => (window as any).Clerk?.client, {
      timeout: 60_000,
    });
    await page.evaluate(
      async ({ email, password }) => {
        const clerk = (window as any).Clerk;
        const signIn = await clerk.client.signIn.create({
          identifier: email,
          password,
        });
        if (signIn.status !== 'complete') {
          throw new Error(`signIn status: ${signIn.status}`);
        }
        await clerk.setActive({ session: signIn.createdSessionId });
      },
      { email, password },
    );
  } else {
    // --- Caminho 2: login manual ---
    console.log('\n=== LOGIN MANUAL NECESSARIO ===');
    console.log(`Abri ${APP_URL} — faz login na janela do browser.`);
    console.log('Recomendado: conta de teste dedicada (ex: teu_email+e2e@...).');
    console.log('A aguardar sessao Clerk (timeout 5 min)...\n');
    await page.goto(APP_URL);
    await page.waitForFunction(
      () => (window as any).Clerk?.session?.id != null,
      { timeout: 300_000, polling: 1000 },
    );
    // Pequena pausa para o app sincronizar o estado.
    await page.waitForTimeout(2000);
  }

  const userId = await page.evaluate(
    () => (window as any).Clerk?.user?.id ?? null,
  );
  if (!userId) throw new Error('Sessao criada mas user.id ausente');
  console.log(`Sessao capturada para ${userId}`);

  await context.storageState({ path: AUTH_FILE });
  await browser.close();

  // Verifica que a sessao restaura num contexto novo (cookies 3rd-party).
  const verifyBrowser = await chromium.launch();
  const verifyCtx = await verifyBrowser.newContext({ storageState: AUTH_FILE });
  const verifyPage = await verifyCtx.newPage();
  await verifyPage.goto(APP_URL, { waitUntil: 'domcontentloaded' });
  try {
    await verifyPage.waitForFunction(
      () => (window as any).Clerk?.session?.id != null,
      { timeout: 90_000, polling: 2000 },
    );
    console.log('Sessao restaurada com sucesso em contexto novo.');
  } catch {
    console.warn(
      'AVISO: a sessao nao restaurou num contexto novo. Os testes autenticados ' +
        'podem falhar — corre de novo `npm run auth` ou usa CLERK_SECRET_KEY.',
    );
  }
  await verifyBrowser.close();
});
