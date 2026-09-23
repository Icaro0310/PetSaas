import { test, expect } from '@playwright/test';
import { APP_URL } from '../playwright.config';

// App hospedada no GitHub Pages sob o subpath /PetSaas/app
const APP_LOGIN = `${APP_URL}/login`;

test.describe('CTAs de conta - o site convida a registar-se', () => {
  test('header tem Entrar + Criar conta grátis', async ({ page }, testInfo) => {
    test.skip(
      testInfo.project.name !== 'desktop',
      'no mobile os links vivem no overlay (teste proprio)'
    );
    await page.goto('./');
    const nav = page.locator('.site-nav__links');
    const entrar = nav.getByRole('link', { name: 'Entrar', exact: true });
    const criar = nav.getByRole('link', { name: 'Criar conta grátis' });
    await expect(entrar).toBeVisible();
    await expect(criar).toBeVisible();
    await expect(entrar).toHaveAttribute('href', APP_LOGIN);
    await expect(criar).toHaveAttribute('href', APP_LOGIN);
  });

  test('hero tem CTA de criacao de conta + login', async ({ page }) => {
    await page.goto('./');
    const hero = page.locator('.hero');
    await expect(
      hero.getByRole('link', { name: 'Criar conta grátis' })
    ).toBeVisible();
    await expect(
      hero.getByRole('link', { name: 'Entrar na minha conta' })
    ).toBeVisible();
    await expect(hero).toContainText('grátis');
  });

  test('home tem CTA de conta em pelo menos 4 pontos', async ({ page }) => {
    await page.goto('./');
    const ctas = page.getByRole('link', { name: 'Criar conta grátis' });
    expect(await ctas.count()).toBeGreaterThanOrEqual(4);
  });

  test('faixa CTA intermedia presente e clicavel', async ({ page }) => {
    await page.goto('./');
    const strip = page.locator('.cta-strip');
    await strip.scrollIntoViewIfNeeded();
    await expect(strip).toContainText('Pronto para começar?');
    await expect(
      strip.getByRole('link', { name: 'Criar conta grátis' })
    ).toBeVisible();
  });

  test('clique no CTA abre a app na página de login', async ({ page }) => {
    await page.goto('./');
    const criar = page
      .locator('.hero')
      .getByRole('link', { name: 'Criar conta grátis' });
    await criar.click();
    // GitHub Pages: /PetSaas/app/login -> 404.html -> ?p= -> replaceState.
    await page.waitForURL(/\/PetSaas\/app\/login/, { timeout: 30000 });
  });

  test('raiz da app responde 200', async ({ request }) => {
    const res = await request.get(`${APP_URL}/`);
    expect(res.status()).toBe(200);
  });

  test('rota profunda /app/login resolve via fallback 404', async ({
    page,
  }) => {
    // Acesso direto a rota SPA: Pages serve 404.html que redireciona
    // para ?p= e a app restaura a URL limpa.
    await page.goto(`${APP_URL}/login`);
    await page.waitForURL(/\/PetSaas\/app\/login/, { timeout: 30000 });
  });

  test('overlay mobile tem Entrar + Criar conta grátis', async ({
    page,
  }, testInfo) => {
    test.skip(testInfo.project.name !== 'mobile', 'overlay so existe no mobile');
    await page.goto('./');
    await page.getByRole('button', { name: 'Menu' }).click();
    const overlay = page.locator('#navOverlay');
    await expect(
      overlay.getByRole('link', { name: 'Entrar', exact: true })
    ).toBeVisible();
    await expect(
      overlay.getByRole('link', { name: 'Criar conta grátis' })
    ).toBeVisible();
  });

  test('nao ha texto de pricing/Premium visivel (app gratuita)', async ({
    page,
  }) => {
    for (const path of ['./', 'pricing.html', 'terms.html']) {
      await page.goto(path);
      const body = await page.locator('body').innerText();
      expect(body, `${path} contem texto pago visivel`).not.toMatch(
        /premium|1,99|19,99|teste gratis|14 dias de teste|experimentar 14 dias/i
      );
    }
  });

  test('pricing.html: card Free diz tudo incluido e CTA e criar conta', async ({
    page,
  }) => {
    await page.goto('pricing.html');
    await expect(page.locator('h1')).toContainText('PetCare é gratuito');
    const card = page.locator('.price-card');
    await expect(card).toContainText('Perfis para vários animais');
    await expect(
      card.getByRole('link', { name: 'Criar conta grátis' })
    ).toBeVisible();
  });
});
