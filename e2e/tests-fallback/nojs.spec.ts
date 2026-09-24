import { test, expect } from '@playwright/test';
import { SITE_URL } from '../playwright.config';

/**
 * FALLBACK Playwright — testes que o Cypress nao consegue executar.
 *
 * O Cypress injeta-se na pagina via JavaScript, por isso nao consegue
 * validar a renderizacao sem JS. O Playwright suporta contextos com
 * javaScriptEnabled: false — este teste fica aqui.
 */
test.describe('Fallback: cenarios que o Cypress nao cobre', () => {
  test('sem JavaScript o conteudo continua visivel', async ({ browser }) => {
    const context = await browser.newContext({ javaScriptEnabled: false });
    const page = await context.newPage();
    await page.goto(`${SITE_URL}/`);
    await expect(page.locator('h1').first()).toBeVisible();
    // Sem JS o html nunca ganha a classe .js — .reveal fica sempre visivel
    // (.js .reveal { opacity: 0 } so se aplica com scripting ativo).
    const hiddenReveals = await page.evaluate(() =>
      Array.from(document.querySelectorAll('.reveal')).filter(
        (el) => getComputedStyle(el).opacity === '0'
      ).length
    );
    expect(hiddenReveals).toBe(0);
    await context.close();
  });
});
