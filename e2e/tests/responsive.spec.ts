import { test, expect } from '@playwright/test';

test.describe('Responsividade', () => {
  test('mobile: sem scroll horizontal', async ({ page }, testInfo) => {
    test.skip(testInfo.project.name !== 'mobile', 'apenas viewport mobile');
    for (const path of ['./', 'pricing.html', 'privacy.html', 'terms.html']) {
      await page.goto(path);
      const dims = await page.evaluate(() => ({
        scroll: document.documentElement.scrollWidth,
        client: document.documentElement.clientWidth,
      }));
      expect(
        dims.scroll,
        `${path} tem overflow horizontal`
      ).toBeLessThanOrEqual(dims.client + 1);
    }
  });

  test('sem overflow horizontal nos principais breakpoints', async ({ page }) => {
    await page.goto('./');
    for (const width of [320, 375, 414, 768, 1024, 1280, 1920]) {
      await page.setViewportSize({ width, height: 900 });
      const dimensions = await page.evaluate(() => ({
        scroll: document.documentElement.scrollWidth,
        client: document.documentElement.clientWidth,
      }));
      expect(dimensions.scroll, `overflow a ${width}px`).toBeLessThanOrEqual(
        dimensions.client + 1,
      );
    }
  });

  test('mobile: menu overlay abre e fecha', async ({ page }, testInfo) => {
    test.skip(testInfo.project.name !== 'mobile', 'apenas viewport mobile');
    await page.goto('./');

    const toggle = page.getByRole('button', { name: 'Menu', exact: true });
    await expect(toggle).toBeVisible();
    await toggle.click();

    const overlay = page.locator('#navOverlay');
    await expect(overlay).toBeVisible();
    await expect(toggle).toHaveAttribute('aria-expanded', 'true');

    await page.getByRole('button', { name: 'Fechar menu' }).click();
    await expect(toggle).toHaveAttribute('aria-expanded', 'false');
  });

  test('desktop: nav links visiveis sem menu hamburger', async ({
    page,
  }, testInfo) => {
    test.skip(testInfo.project.name !== 'desktop', 'apenas desktop');
    await page.goto('./');
    await expect(page.locator('.site-nav__links')).toBeVisible();
    await expect(
      page.getByRole('button', { name: 'Menu' })
    ).not.toBeVisible();
  });

  test('reduced-motion: conteudo .reveal nunca fica invisivel', async ({
    page,
  }) => {
    await page.emulateMedia({ reducedMotion: 'reduce' });
    await page.goto('./');
    // Com reduced-motion o CSS/JS deve revelar tudo sem animacao
    const hidden = await page.evaluate(() => {
      const els = Array.from(document.querySelectorAll('.reveal'));
      return els.filter((el) => getComputedStyle(el).opacity === '0').length;
    });
    expect(hidden).toBe(0);
  });
});
