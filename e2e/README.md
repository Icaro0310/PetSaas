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
| `tests/auth.setup.ts` | Captura a sessao Clerk (manual headed ou testing token) para `.auth/session.json` |
| `tests/app/pets.spec.ts` | Form de pet: validacao nome/peso, criar sem foto, criar com foto (upload real), editar |
| `tests/app/medications.spec.ts` | Criar medicacao diaria, dose de hoje visivel, "Dar remedio" marca `given` |
| `tests/app/caregivers.spec.ts` | Validacao email, convite, cuidador na lista, remover |
| `tests/app/z_logout.spec.ts` | Perfil (email/atalhos) + logout volta ao login |
| `tests/app/account.spec.ts` | Eliminar conta — so com `E2E_ALLOW_DELETE_ACCOUNT=1` e conta de teste dedicada |

## Testes autenticados da app (Flutter Web)

A app e canvas — os testes usam a arvore de semantica do Flutter
(`flt-semantics`), ativada automaticamente pelos helpers em `helpers/app.ts`.

### 1. Capturar sessao (uma vez, ~7 dias de validade)

```bash
cd e2e
npm run auth        # abre browser visivel; faz login manual (CAPTCHA humano)
```

Usa uma **conta de teste dedicada** (ex: `teu_email+e2e@gmail.com` ou um
endereco `*+clerk_test@example.com` com codigo `424242`) — nunca a conta
pessoal, porque os testes criam dados e ha um teste de eliminar conta.

Alternativa headless (CI): exporta `CLERK_SECRET_KEY` (sk_test da instancia
dev), `E2E_EMAIL`, `E2E_PASSWORD` — usa o endpoint de testing tokens.

### 2. Correr a suite da app

```bash
npm run test:app    # projeto `app` com storageState da sessao
```

Sem sessao, os testes autenticados sao skipped. Dados de teste usam nomes
`* E2E *` e sao apagados no `afterAll` (delete via REST, respeita RLS).

### Gaps conhecidos (nao existem na app — nao sao bugs de teste)

- Sem "remover pet" (nao ha UI/endpoint de delete de pet)
- Sem "passeios"/walks (feature nunca implementada; removida do marketing)
- Edicao de perfil nao existe fora do onboarding

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
