import { test, expect } from '@playwright/test';
import { SITE_URL } from '../playwright.config';

const SUBSCRIBE_URL =
  'https://dotplnbakltelacsxvjz.supabase.co/functions/v1/subscribe';

// Suite de fragilidade UAT: falhas de rede, teclado, a11y, sem-JS, assets.
test.describe('Robustez UAT - cenarios de falha e acessibilidade', () => {
  test('rede em baixo: erro visivel e botao reabilitado', async ({ page }) => {
    await page.route(SUBSCRIBE_URL, (route) => route.abort());
    await page.goto('./');
    const form = page.locator('[data-subscribe]').first();
    const button = form.locator('button[type="submit"]');
    await form.locator('input[type="email"]').fill('falha@example.com');
    await button.click();
    await expect(page.locator('.subscribe__msg').first()).toContainText(
      'Nao foi possivel'
    );
    await expect(button).toBeEnabled();
  });

  test('resposta lenta: botao fica disabled e recupera no fim', async ({
    page,
  }) => {
    await page.route(SUBSCRIBE_URL, async (route) => {
      await new Promise((r) => setTimeout(r, 1200));
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: '{"success":true}',
      });
    });
    await page.goto('./');
    const form = page.locator('[data-subscribe]').first();
    const button = form.locator('button[type="submit"]');
    await form.locator('input[type="email"]').fill('lento@example.com');
    await button.click();
    await expect(button).toBeDisabled();
    await expect(page.locator('.subscribe__msg').first()).toContainText(
      'Subscricao confirmada',
      { timeout: 10000 }
    );
    await expect(button).toBeEnabled();
  });

  test('resposta 500 do servidor: erro generico, sem crash', async ({
    page,
  }) => {
    await page.route(SUBSCRIBE_URL, (route) =>
      route.fulfill({
        status: 500,
        contentType: 'application/json',
        body: '{"error":"internal"}',
      })
    );
    await page.goto('./');
    const form = page.locator('[data-subscribe]').first();
    await form.locator('input[type="email"]').fill('erro@example.com');
    await form.locator('button[type="submit"]').click();
    await expect(page.locator('.subscribe__msg').first()).toContainText(
      'Nao foi possivel'
    );
  });

  test('Escape fecha o overlay mobile', async ({ page }, testInfo) => {
    test.skip(testInfo.project.name !== 'mobile', 'overlay so existe no mobile');
    await page.goto('./');
    await page
      .getByRole('button', { name: 'Menu', exact: true })
      .click();
    await expect(page.locator('#navOverlay')).toBeVisible();
    await page.keyboard.press('Escape');
    await expect(
      page.getByRole('button', { name: 'Menu', exact: true })
    ).toHaveAttribute('aria-expanded', 'false');
  });

  test('teclado: Tab alcanca links de navegacao', async ({
    page,
  }, testInfo) => {
    test.skip(testInfo.project.name !== 'desktop', 'apenas desktop');
    await page.goto('./');
    await page.keyboard.press('Tab');
    const focused = await page.evaluate(
      () => document.activeElement?.tagName
    );
    expect(['A', 'BUTTON']).toContain(focused);
  });

  test('email invalido marca aria-invalid no input', async ({ page }) => {
    await page.goto('./');
    const form = page.locator('[data-subscribe]').first();
    const input = form.locator('input[type="email"]');
    await input.fill('nao-e-email');
    await form.locator('button[type="submit"]').click();
    await expect(input).toHaveAttribute('aria-invalid', 'true');
  });

  test('mensagem de estado usa regiao aria-live', async ({ page }) => {
    await page.goto('./');
    await expect(page.locator('.subscribe__msg').first()).toHaveAttribute(
      'aria-live',
      'polite'
    );
  });

  test('pagina inexistente devolve 404', async ({ request }) => {
    const res = await request.get(
      `${SITE_URL}/pagina-que-nao-existe-${Date.now()}.html`
    );
    expect(res.status()).toBe(404);
  });

  test('favicon carrega', async ({ request }) => {
    const res = await request.get(`${SITE_URL}/assets/favicon.png`);
    expect(res.status()).toBe(200);
  });

  test('sem JavaScript o conteudo continua visivel', async ({ browser }) => {
    const context = await browser.newContext({ javaScriptEnabled: false });
    const page = await context.newPage();
    await page.goto(`${SITE_URL}/`);
    await expect(page.locator('h1').first()).toBeVisible();
    const hiddenReveals = await page.evaluate(() =>
      Array.from(document.querySelectorAll('.reveal')).filter(
        (el) => getComputedStyle(el).opacity === '0'
      ).length
    );
    expect(hiddenReveals).toBe(0);
    await context.close();
  });

  test('todas as imagens tem alt', async ({ page }) => {
    await page.goto('./');
    const missing = await page.evaluate(() =>
      Array.from(document.querySelectorAll('img'))
        .filter((img) => !img.hasAttribute('alt'))
        .map((img) => img.getAttribute('src'))
    );
    expect(missing).toEqual([]);
  });

  test('links externos com _blank tem rel=noopener', async ({ page }) => {
    await page.goto('./');
    const unsafe = await page.evaluate(() =>
      Array.from(document.querySelectorAll('a[target="_blank"]'))
        .filter((a) => !(a.getAttribute('rel') || '').includes('noopener'))
        .map((a) => a.getAttribute('href'))
    );
    expect(unsafe).toEqual([]);
  });

  test('OG tags essenciais presentes e og:image absoluto', async ({
    page,
  }) => {
    await page.goto('./');
    const og = await page.evaluate(() => {
      const get = (p: string) =>
        document
          .querySelector(`meta[property="${p}"]`)
          ?.getAttribute('content') || '';
      return {
        title: get('og:title'),
        description: get('og:description'),
        image: get('og:image'),
      };
    });
    expect(og.title.length).toBeGreaterThan(0);
    expect(og.description.length).toBeGreaterThan(0);
    expect(og.image).toMatch(/^https:\/\//);
  });
});
