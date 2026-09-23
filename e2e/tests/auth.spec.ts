import { test, expect } from '@playwright/test';
import { APP_URL } from '../playwright.config';

const AUTH_APP_URL = process.env.AUTH_APP_URL;
const APP_BASE = AUTH_APP_URL
  ? AUTH_APP_URL.endsWith('/')
    ? AUTH_APP_URL
    : `${AUTH_APP_URL}/`
  : APP_URL.endsWith('/')
    ? APP_URL
    : `${APP_URL}/`;
const APP_ENTRY = APP_BASE;

test.describe('Autenticação Clerk na Web', () => {
  test.skip(!AUTH_APP_URL, 'Define AUTH_APP_URL para testar o build Web local.');
  test('carrega o ClerkJS e apresenta as ações de conta', async ({ page }) => {
    await page.goto(APP_ENTRY);
    await page.waitForURL(/\/login$/, { timeout: 30_000 });
    await expect(page.getByRole('button', { name: 'Iniciar sessão' })).toBeVisible({
      timeout: 30_000,
    });
    await expect(page.getByRole('button', { name: 'Criar conta grátis' })).toBeVisible();
    await page.waitForFunction(
      () => typeof (window as any).PetCareClerkReady !== 'undefined',
      undefined,
      { timeout: 30_000 },
    );
    const user = await page.evaluate(async () => {
      const api = await (window as any).PetCareClerkReady;
      return api.getUser();
    });
    expect(user).toBe('null');
  });

  test('abre o formulário de início de sessão do Clerk', async ({ page }) => {
    await page.goto(APP_ENTRY);
    await page.waitForURL(/\/login$/, { timeout: 30_000 });
    await page.getByRole('button', { name: 'Iniciar sessão' }).click();
    await expect(page.getByLabel('Endereço de email')).toBeVisible({
      timeout: 20_000,
    });
  });

  test('abre o formulário de criação de conta do Clerk', async ({ page }) => {
    await page.goto(APP_ENTRY);
    await page.waitForURL(/\/login$/, { timeout: 30_000 });
    await page.getByRole('button', { name: 'Criar conta grátis' }).click();
    await expect(page.getByLabel('Endereço de email')).toBeVisible({
      timeout: 20_000,
    });
  });
});
