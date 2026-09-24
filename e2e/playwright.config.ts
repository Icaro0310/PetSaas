import { defineConfig } from '@playwright/test';

/**
 * Playwright = FALLBACK da suite principal Cypress (cypress.config.ts).
 *
 * Cobre apenas o que o Cypress estruturalmente nao consegue fazer:
 * paginas renderizadas sem JavaScript (o Cypress injeta-se na pagina).
 *
 * Corre no Chrome do sistema (channel: 'chrome') — nao precisa de
 * `playwright install` nem em CI nem local.
 */
export const SITE_URL =
  process.env.SITE_URL ?? 'https://icaro0310.github.io/PetSaas';

export default defineConfig({
  testDir: './tests-fallback',
  timeout: 60_000,
  retries: process.env.CI ? 1 : 0,
  reporter: [['list']],
  use: {
    channel: process.env.PW_CHANNEL ?? 'chrome',
    baseURL: SITE_URL.endsWith('/') ? SITE_URL : `${SITE_URL}/`,
    screenshot: 'only-on-failure',
  },
});
