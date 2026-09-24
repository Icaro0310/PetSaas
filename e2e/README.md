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
| `tests/app/pets.spec.ts` | Form de pet: validacao nome/peso, criar sem foto, criar com foto (upload real), editar |
| `tests/app/medications.spec.ts` | Criar medicacao diaria, dose de hoje visivel, "Dar remedio" marca `given` |
| `tests/app/caregivers.spec.ts` | Validacao email, convite, cuidador na lista, remover |
| `tests/app/z_logout.spec.ts` | Perfil (email/atalhos) + logout volta ao login |
| `tests/app/account.spec.ts` | Eliminar conta — so com `E2E_ALLOW_DELETE_ACCOUNT=1` e conta de teste dedicada |

## Testes autenticados da app (Flutter Web)

A app e canvas — os testes usam a arvore de semantica do Flutter
(`flt-semantics`), ativada automaticamente pelos helpers em `helpers/app.ts`.
Text fields aparecem como `<input data-semantics-role="text-field" aria-label="...">`
dentro do no `flt-semantics` — o `fillField` preenche esse input.

### Autenticacao programatica (sem login manual)

Cada contexto autentica-se sozinho em `openApp()` via
`Clerk.client.signIn` — **sem storageState nem sessao partilhada**
(o logout de um teste nao mata os outros).

Conta por omissao: `petcare.e2e+clerk_test@example.com` com `email_code`
fixo `424242` (emails `+clerk_test` em instancias dev verificam sempre
com este codigo). O utilizador tem de **existir** — criar uma vez via UI
da app (o CAPTCHA Turnstile so bloqueia sign-up, nao sign-in), ou desligar
"Bot sign-up protection" no Clerk dev dashboard para auto-provisionar.

Alternativa com conta real:

```bash
E2E_EMAIL=conta@exemplo.com E2E_PASSWORD=senha npx playwright test --project=app
```

(Nunca commitar credenciais — sao env vars.)

### Correr a suite da app

```bash
npm run test:app    # projeto `app`
```

Dados de teste usam nomes `* E2E *` e cada spec apaga os seus no `afterAll`
por prefixo (`Rex E2E`, `MedPet E2E`, `CgPet E2E`) — isolamento entre
workers paralelos.

### Gaps conhecidos (nao existem na app — nao sao bugs de teste)

- Sem "remover pet" (nao ha UI/endpoint de delete de pet)
- Sem "passeios"/walks (feature nunca implementada; removida do marketing)
- Edicao de perfil nao existe fora do onboarding
- Cuidador removido fica visivel na lista com estado "Removido" (soft-delete)

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
