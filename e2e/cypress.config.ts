import { defineConfig } from 'cypress';

/**
 * PetCare E2E — suite principal em Cypress.
 *
 * Corre contra o site em producao por omissao. Overrides via env:
 *   CYPRESS_SITE_URL  / SITE_URL   - website em teste
 *   CYPRESS_APP_URL   / APP_URL    - Flutter web app
 *   CYPRESS_SB_URL    / SB_URL     - Supabase project URL
 *   CYPRESS_SB_ANON_KEY / SB_ANON_KEY - publishable key (publica por design)
 *   CYPRESS_E2E_EMAIL / E2E_EMAIL  - conta de teste (default clerk_test)
 *   CYPRESS_E2E_PASSWORD / E2E_PASSWORD - conta real (opcional)
 *   CYPRESS_E2E_ALLOW_DELETE_ACCOUNT=1 - desbloqueia o teste destrutivo
 *
 * Playwright continua como fallback para o que o Cypress nao consegue
 * fazer (ex.: pagina sem JavaScript) — ver tests-fallback/.
 */

const pick = (env: string, plain: string, dflt: string) =>
  process.env[env] ?? process.env[plain] ?? dflt;

const SITE_URL = pick(
  'CYPRESS_SITE_URL',
  'SITE_URL',
  'https://icaro0310.github.io/PetSaas',
);

export default defineConfig({
  e2e: {
    specPattern: 'cypress/e2e/**/*.cy.{ts,js}',
    supportFile: 'cypress/support/e2e.ts',
    // baseUrl com o subpath do GitHub Pages — cy.visit('pricing.html')
    // resolve dentro de /PetSaas/.
    baseUrl: SITE_URL,
    viewportWidth: 1440,
    viewportHeight: 900,
    defaultCommandTimeout: 15_000,
    // Boot do Flutter Web no GitHub Pages pode ser lento.
    pageLoadTimeout: 120_000,
    requestTimeout: 30_000,
    responseTimeout: 30_000,
    // Self-healing: retries em run (CI/headless) e tambem no modo
    // interativo (cypress open) — um teste que tropeca num timing
    // transitorio do Flutter re-tenta automaticamente.
    retries: { runMode: 2, openMode: 1 },
    // Cypress 16: Cypress.env() removido.
    // - expose: configuracao publica, segura de ler no browser
    //   (URLs e anon key — esta ja e publica no site.js por design).
    // - env: valores sensiveis lidos apenas via cy.env() (fora do AUT).
    expose: {
      SITE_URL,
      APP_URL: pick(
        'CYPRESS_APP_URL',
        'APP_URL',
        'https://icaro0310.github.io/PetSaas/app',
      ),
      SB_URL: pick(
        'CYPRESS_SB_URL',
        'SB_URL',
        'https://dotplnbakltelacsxvjz.supabase.co',
      ),
      SB_ANON_KEY: pick(
        'CYPRESS_SB_ANON_KEY',
        'SB_ANON_KEY',
        'sb_publishable__Pp5qzGJ2HlZPPD1NEdPSg_ZCCA9I9x',
      ),
      E2E_EMAIL:
        process.env.CYPRESS_E2E_EMAIL ??
        process.env.E2E_EMAIL ??
        'petcare.e2e+clerk_test@example.com',
      E2E_ALLOW_DELETE_ACCOUNT:
        process.env.CYPRESS_E2E_ALLOW_DELETE_ACCOUNT ??
        process.env.E2E_ALLOW_DELETE_ACCOUNT ??
        null,
      AUTH_APP_URL:
        process.env.CYPRESS_AUTH_APP_URL ?? process.env.AUTH_APP_URL ?? null,
      SLOW_MO: process.env.CYPRESS_SLOW_MO ?? process.env.SLOW_MO ?? null,
    },
    env: {
      // Sensivel — nunca exposto ao codigo da pagina.
      E2E_PASSWORD:
        process.env.CYPRESS_E2E_PASSWORD ?? process.env.E2E_PASSWORD ?? null,
    },
  },
});
