# PetCare Website E2E (Playwright)

Suite UAT automatizada que corre **contra o site em producao**
(`icaro0310.github.io/PetSaas`) e contra a Edge Function `subscribe` do
Supabase.

## Suites

| Ficheiro | Cobertura |
|----------|-----------|
| `tests/site.spec.ts` | Smoke: todas as paginas 200, title/h1/meta, assets 200, links internos, sem erros JS |
| `tests/cta.spec.ts` | CTAs de criacao de conta/login em todo o site, popup abre `/login`, sem texto Premium visivel |
| `tests/subscribe.spec.ts` | Formulario waitlist: validacao, sucesso, dedup, estado disabled |
| `tests/api.spec.ts` | Edge Function: CORS, 405, Zod strict, RLS da waitlist, health |
| `tests/responsive.spec.ts` | Sem overflow horizontal, overlay mobile, reduced-motion |

## Correr localmente

```bash
cd e2e
npm ci
npx playwright install chromium
npx playwright test
```

Contra um servidor local:

```bash
SITE_URL=http://localhost:8080 npx playwright test
```

Variaveis: `SITE_URL`, `APP_URL`, `SB_URL`, `SB_ANON_KEY`.

## Cron diario

`.github/workflows/website-e2e.yml` corre todos os dias as 06:17 UTC
(mais `workflow_dispatch` e push em `website/**`/`e2e/**`).

Notas:
- Os testes de API so correm no projeto `desktop` para nao duplicar
  chamadas (rate limit do subscribe: 5/hora por IP).
- O email `e2e+website@petcare.dev` fica na waitlist (dedup seguro).
- Rate limiting (429) nao e testado no cron para nao poluir a waitlist.
