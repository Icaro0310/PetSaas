# PetCare E2E — Cypress (principal) + Playwright (fallback)

Suite UAT automatizada que corre **contra o site em producao**
(`icaro0310.github.io/PetSaas`), contra a app Flutter Web
(`/PetSaas/app`) e contra as Edge Functions do Supabase.

## Arquitetura

| Ferramenta | Papel | Cobertura |
|---|---|---|
| **Cypress** | Suite principal | Tudo: site, API, responsivo, hardening, app autenticada |
| **Playwright** | Fallback | Apenas o que o Cypress nao consegue executar |

O Cypress injeta-se na pagina via JavaScript — por isso o unico teste que
lhe e impossivel e validar a renderizacao **sem JS**. Esse teste fica em
`tests-fallback/` (Playwright com `javaScriptEnabled: false`, Chrome do
sistema — sem `playwright install`). No CI ambos correm como cross-check.

## Suites Cypress

| Ficheiro | Cobertura |
|----------|-----------|
| `cypress/e2e/site.cy.ts` | Smoke: paginas 200, title/h1/meta, assets 200, links internos, sem erros JS |
| `cypress/e2e/cta.cy.ts` | CTAs de conta em todo o site, deep link /app/login, sem texto Premium |
| `cypress/e2e/subscribe.cy.ts` | Formulario waitlist: validacao, sucesso, dedup |
| `cypress/e2e/api.cy.ts` | Edge Function: CORS, 405, Zod strict, RLS da waitlist, health |
| `cypress/e2e/responsive.cy.ts` | Sem overflow horizontal (7 breakpoints), overlay mobile, reduced-motion via CDP |
| `cypress/e2e/hardening.cy.ts` | Falhas de rede (intercept), Tab/Escape reais, a11y, OG tags, 404, favicon |
| `cypress/e2e/auth.cy.ts` | Clerk UI — so com `AUTH_APP_URL` (build local) |
| `cypress/e2e/app/pets.cy.ts` | Form de pet: validacao, criar sem foto, criar com foto (upload real), editar |
| `cypress/e2e/app/medications.cy.ts` | Medicacao diaria, dose de hoje, "Dar remedio" marca `given` |
| `cypress/e2e/app/caregivers.cy.ts` | Validacao email, convite, cuidador na lista, remover |
| `cypress/e2e/app/z_logout.cy.ts` | Perfil (atalhos) + logout volta ao login |
| `cypress/e2e/app/account.cy.ts` | Eliminar conta — so com `E2E_ALLOW_DELETE_ACCOUNT=1` e conta clerk_test |

## Testes autenticados da app (Flutter Web)

A app e canvas — os testes usam a arvore de semantica do Flutter
(`flt-semantics`), ativada automaticamente por `cy.enableSemantics()`.
Text fields aparecem como `<input data-semantics-role="text-field"
aria-label="...">` dentro do no `flt-semantics` — o `cy.fillField()`
preenche esse input.

Comandos em `cypress/support/commands.ts`: `openApp`, `enableSemantics`,
`semNode`, `semButton`, `tapButton`, `tapAndWait`, `openPet`, `fillField`,
`clerkUserId`, `sbRest`, `createPetViaApi`, `cleanupTestPets`,
`emulateReducedMotion`.

### Autenticacao programatica (sem login manual)

Cada teste autentica-se sozinho em `cy.openApp()` via
`Clerk.client.signIn` — sem sessao partilhada (o logout de um teste nao
mata os outros).

Conta por omissao: `petcare.e2e+clerk_test@example.com` com `email_code`
fixo `424242` (emails `+clerk_test` em instancias dev verificam sempre
com este codigo). O utilizador tem de **existir** — criar uma vez via UI
da app (o CAPTCHA Turnstile so bloqueia sign-up, nao sign-in), ou desligar
"Bot sign-up protection" no Clerk dev dashboard para auto-provisionar.

Alternativa com conta real:

```bash
E2E_EMAIL=conta@exemplo.com E2E_PASSWORD=senha npm run test:app
```

(Nunca commitar credenciais — sao env vars.)

## Correr localmente

```bash
cd e2e
npm ci

npm test              # suite Cypress completa (headless)
npm run test:headed   # suite visivel (Chrome headed)
npm run test:open     # Cypress App interativo
npm run test:app      # so a app autenticada
npm run test:fallback # fallback Playwright (sem JS)
npm run test:all      # Cypress + fallback (cross-check)
```

Contra um servidor local:

```bash
SITE_URL=http://localhost:8080 npm test
```

Variaveis: `SITE_URL`, `APP_URL`, `SB_URL`, `SB_ANON_KEY`,
`E2E_EMAIL`, `E2E_PASSWORD`, `AUTH_APP_URL`,
`E2E_ALLOW_DELETE_ACCOUNT` (aceitam prefixo `CYPRESS_` ou nome direto).

Dados de teste usam nomes `* E2E *` e cada spec apaga os seus no `after`
por prefixo (`Rex E2E`, `MedPet E2E`, `CgPet E2E`, `Foto E2E`).

### Gaps conhecidos (nao existem na app — nao sao bugs de teste)

- Sem "remover pet" (nao ha UI/endpoint de delete de pet)
- Sem "passeios"/walks (feature nunca implementada; removida do marketing)
- Edicao de perfil nao existe fora do onboarding
- Cuidador removido fica visivel na lista com estado "Removido" (soft-delete)

## Cron diario

`.github/workflows/website-e2e.yml` corre todos os dias as 06:17 UTC
(mais `workflow_dispatch` e push em `website/**`/`e2e/**`): Cypress no
Chrome via `cypress-io/github-action`, depois o fallback Playwright no
Chrome do sistema.

Notas:
- Rate limiting (429) do subscribe nao e testado no cron para nao poluir
  a waitlist.
- O email `e2e+website@petcare.dev` fica na waitlist (dedup seguro).
