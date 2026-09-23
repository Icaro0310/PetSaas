import { test, expect } from '@playwright/test';
import { APP_URL } from '../playwright.config';

const APP_HOST = 'moonlit-pothos-c56cd4.netlify.app';

test.describe('CTAs de conta - o site convida a registar-se', () => {
  test('header tem Entrar + Criar conta gratis', async ({ page }, testInfo) => {
    test.skip(
      testInfo.project.name !== 'desktop',
      'no mobile os links vivem no overlay (teste proprio)'
    );
    await page.goto('./');
    const nav = page.locator('.site-nav__links');
    const entrar = nav.getByRole('link', { name: 'Entrar', exact: true });
    const criar = nav.getByRole('link', { name: 'Criar conta gratis' });
    await expect(entrar).toBeVisible();
    await expect(criar).toBeVisible();
    await expect(entrar).toHaveAttribute('href', new RegExp(`${APP_HOST}/login`));
    await expect(criar).toHaveAttribute('href', new RegExp(`${APP_HOST}/login`));
  });

  test('hero tem CTA de criacao de conta + login', async ({ page }) => {
    await page.goto('./');
    const hero = page.locator('.hero');
    await expect(
      hero.getByRole('link', { name: 'Criar conta gratis' })
    ).toBeVisible();
    await expect(
      hero.getByRole('link', { name: 'Entrar na minha conta' })
    ).toBeVisible();
    await expect(hero).toContainText('100% gratuito');
  });

  test('home tem CTA de conta em pelo menos 4 pontos', async ({ page }) => {
    await page.goto('./');
    const ctas = page.getByRole('link', { name: 'Criar conta gratis' });
    expect(await ctas.count()).toBeGreaterThanOrEqual(4);
  });

  test('faixa CTA intermedia presente e clicavel', async ({ page }) => {
    await page.goto('./');
    const strip = page.locator('.cta-strip');
    await strip.scrollIntoViewIfNeeded();
    await expect(strip).toContainText('Pronto para comecar?');
    await expect(
      strip.getByRole('link', { name: 'Criar conta gratis' })
    ).toBeVisible();
  });

  test('clique no CTA abre a app na pagina de login', async ({ page, context }) => {
    await page.goto('./');
    const criar = page
      .locator('.hero')
      .getByRole('link', { name: 'Criar conta gratis' });
    const [popup] = await Promise.all([
      context.waitForEvent('page'),
      criar.click(),
    ]);
    await popup.waitForLoadState('domcontentloaded');
    expect(popup.url()).toContain(`${APP_HOST}/login`);
    await popup.close();
  });

  test('destino /login da app responde 200', async ({ request }) => {
    const res = await request.get(`${APP_URL}/login`);
    expect(res.status()).toBe(200);
  });

  test('overlay mobile tem Entrar + Criar conta gratis', async ({
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
      overlay.getByRole('link', { name: 'Criar conta gratis' })
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
    await expect(page.locator('h1')).toContainText('Gratuito');
    const card = page.locator('.price-card');
    await expect(card).toContainText('Pets ilimitados');
    await expect(
      card.getByRole('link', { name: 'Criar conta gratis' })
    ).toBeVisible();
  });
});
