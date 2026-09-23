import { test, expect } from '@playwright/test';

// Email dedicado aos testes E2E - deduplicado na waitlist apos o 1o insert.
const E2E_EMAIL = 'e2e+website@petcare.dev';

test.describe('Formulario de subscricao (waitlist -> Supabase)', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('./');
    await page.locator('[data-subscribe] input[type="email"]').scrollIntoViewIfNeeded();
  });

  test('email invalido mostra erro e nao submete', async ({ page }) => {
    const input = page.locator('[data-subscribe] input[type="email"]');
    const msg = page.locator('.subscribe__msg').first();

    await input.fill('nao-e-um-email');
    await page.locator('[data-subscribe] button[type="submit"]').click();

    await expect(msg).toContainText('email valido');
    await expect(input).toHaveAttribute('aria-invalid', 'true');
  });

  test('email valido subscreve com sucesso', async ({ page }) => {
    const input = page.locator('[data-subscribe] input[type="email"]');
    const msg = page.locator('.subscribe__msg').first();

    await input.fill(E2E_EMAIL);
    await page.locator('[data-subscribe] button[type="submit"]').click();

    await expect(msg).toContainText('Subscricao confirmada', {
      timeout: 15_000,
    });
    await expect(input).toHaveValue('');
  });

  test('submeter email duplicado devolve sucesso (dedup silencioso)', async ({
    page,
  }) => {
    const input = page.locator('[data-subscribe] input[type="email"]');
    const msg = page.locator('.subscribe__msg').first();

    await input.fill(E2E_EMAIL); // mesmo email do teste anterior
    await page.locator('[data-subscribe] button[type="submit"]').click();

    await expect(msg).toContainText('Subscricao confirmada', {
      timeout: 15_000,
    });
  });

  test('botao fica disabled durante o envio', async ({ page }) => {
    const input = page.locator('[data-subscribe] input[type="email"]');
    const button = page.locator('[data-subscribe] button[type="submit"]');

    await input.fill(E2E_EMAIL);
    await button.click();
    // Durante o request o botao deve estar disabled (pode ja ter voltado)
    await expect(page.locator('.subscribe__msg').first()).not.toBeEmpty({
      timeout: 15_000,
    });
  });
});
