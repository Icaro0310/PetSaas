import { defineConfig, devices } from '@playwright/test';

/**
 * PetCare website E2E/UAT suite.
 *
 * Targets the LIVE site by default. Override with env vars:
 *   SITE_URL   - website under test (default: GitHub Pages)
 *   APP_URL    - Flutter web app (default: GitHub Pages /PetSaas/app)
 *   SB_URL     - Supabase project URL
 *   SB_ANON_KEY- Supabase publishable/anon key (public by design)
 */
export const SITE_URL =
  process.env.SITE_URL ?? 'https://icaro0310.github.io/PetSaas';
export const APP_URL =
  process.env.APP_URL ?? 'https://icaro0310.github.io/PetSaas/app';
export const SB_URL =
  process.env.SB_URL ?? 'https://dotplnbakltelacsxvjz.supabase.co';
export const SB_ANON_KEY =
  process.env.SB_ANON_KEY ??
  'sb_publishable__Pp5qzGJ2HlZPPD1NEdPSg_ZCCA9I9x';
export const SUBSCRIBE_URL = `${SB_URL}/functions/v1/subscribe`;
export const ALLOWED_ORIGIN = new URL(SITE_URL).origin;

export default defineConfig({
  testDir: './tests',
  timeout: 45_000,
  expect: { timeout: 10_000 },
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 2 : undefined,
  reporter: [
    ['list'],
    ['html', { outputFolder: 'playwright-report', open: 'never' }],
    ['junit', { outputFile: 'results/junit.xml' }],
  ],
  use: {
    // trailing slash para paths relativos ('pricing.html') resolverem
    // dentro do subpath do GitHub Pages (/PetSaas/)
    baseURL: SITE_URL.endsWith('/') ? SITE_URL : `${SITE_URL}/`,
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    {
      name: 'desktop',
      use: { ...devices['Desktop Chrome'], viewport: { width: 1440, height: 900 } },
    },
    {
      name: 'mobile',
      use: { ...devices['Pixel 7'], viewport: { width: 390, height: 844 } },
    },
  ],
});
