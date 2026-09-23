import { test, expect } from '@playwright/test';
import { SITE_URL } from '../playwright.config';

const PAGES = [
  { path: './', name: 'home' },
  { path: 'pricing.html', name: 'pricing' },
  { path: 'privacy.html', name: 'privacy' },
  { path: 'terms.html', name: 'terms' },
];

test.describe('Site smoke - paginas carregam corretamente', () => {
  for (const { path, name } of PAGES) {
    test(`${name}: HTTP 200, title, h1 unico, meta description`, async ({ page }) => {
      const errors: string[] = [];
      page.on('pageerror', (e) => errors.push(e.message));

      const res = await page.goto(path);
      expect(res?.status(), `${name} status`).toBe(200);

      await expect(page).toHaveTitle(/PetCare/);
      await expect(page.locator('h1')).toHaveCount(1);
      await expect(page.locator('meta[name="description"]')).toHaveAttribute(
        'content',
        /.+/
      );

      // Sem erros de JS na pagina
      expect(errors).toEqual([]);
    });
  }

  test('assets referenciados na home respondem 200', async ({ page, request }) => {
    await page.goto('./');
    const assets = await page.evaluate(() => {
      const urls: string[] = [];
      document
        .querySelectorAll('img[src], script[src], link[rel="stylesheet"][href]')
        .forEach((el) => {
          const u = el.getAttribute('src') ?? el.getAttribute('href');
          if (u && !u.startsWith('data:')) urls.push(u);
        });
      return urls;
    });
    expect(assets.length).toBeGreaterThan(0);
    for (const u of assets) {
      const res = await request.get(new URL(u, SITE_URL + '/').toString());
      expect(res.status(), `asset ${u}`).toBe(200);
    }
  });

  test('links internos do site resolvem (sem 404)', async ({ page, request }) => {
    await page.goto('./');
    const hrefs = await page.evaluate(() =>
      Array.from(document.querySelectorAll('a[href]'))
        .map((a) => a.getAttribute('href')!)
        .filter((h) => !h.startsWith('http') && !h.startsWith('mailto:') && !h.startsWith('#'))
    );
    const unique = [...new Set(hrefs)];
    for (const h of unique) {
      const res = await request.get(new URL(h, SITE_URL + '/').toString());
      expect(res.status(), `link ${h}`).toBe(200);
    }
  });

  test('termos refletem servico gratuito', async ({ page }) => {
    await page.goto('terms.html');
    await expect(page.locator('body')).toContainText('Servico gratuito');
  });
});
