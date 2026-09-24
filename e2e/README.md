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

## Organizacao — um teste por spec

Cada ficheiro `.cy.ts` contem **um unico teste** (`it`), com um cabecalho
em estilo Gherkin (Funcionalidade / Cenario / Dado / Quando / Entao) em
portugues neutro — qualquer pessoa consegue ler o que o teste valida sem
conhecer o codigo.

| Pasta | Testes | Cobertura |
|---|---|---|
| `cypress/e2e/01-site/` | 7 | Paginas 200, title/h1/meta, assets, links internos, docs legais, sem erros JS |
| `cypress/e2e/02-ctas/` | 10 | CTAs de conta, deep link /app/login, sem texto Premium, pricing "gratuito" |
| `cypress/e2e/03-subscricao/` | 4 | Waitlist: validacao, sucesso, dedup, estado do botao |
| `cypress/e2e/04-api/` | 8 | Edge Function: CORS, 405, Zod strict, RLS da waitlist, health |
| `cypress/e2e/05-responsivo/` | 5 | Sem overflow horizontal, breakpoints, overlay mobile, reduced-motion |
| `cypress/e2e/06-robustez/` | 12 | Falhas de rede, lentidao, 500, Tab/Escape, a11y, 404, favicon, OG |
| `cypress/e2e/07-auth/` | 3 | Clerk UI — so com `AUTH_APP_URL` (build local) |
| `cypress/e2e/app/` | 12 | App autenticada: pets, medicacao, doses, cuidadores, perfil, logout |

Exemplo de spec:

```ts
// Funcionalidade: Gestao de animais
//   Cenario: Criar um animal sem fotografia
//     Dado que estou autenticado na aplicacao
//     Quando crio um animal apenas com o nome
//     Entao o animal aparece na lista "Meus pets"
describe('Gestão de animais', () => {
  it('cria um animal sem fotografia e mostra-o na lista', () => { ... });
});
```

## Self-healing e ritmo legivel

- **Retries**: `runMode: 2` (CI/headless) e `openMode: 1` (Cypress App) —
  um tropeco num timing transitorio do Flutter re-tenta sozinho.
- **Polling imune a rebuilds**: `findSem`/`tapAndWait`/`openPet` consultam
  o documento a cada tentativa em vez de reter nos `flt-semantics` que o
  Flutter derruba e recria em transicoes.
- **Setup por spec**: dados de teste criados via REST autenticado no
  `before` — as specs sao independentes e paralelizaveis.
- **Ritmo humano (`SLOW_MO`)**: em modo headed/interativo cada acao
  visivel (`click`, `type`, `selectFile`...) faz uma pausa de ~900ms para
  ser acompanhada visualmente. Override: `CYPRESS_SLOW_MO=1500` ou
  `CYPRESS_SLOW_MO=0` para desligar. Em headless nao ha pausa (CI rapido).

## Testes autenticados da app (Flutter Web)

A app e canvas — os testes usam a arvore de semantica do Flutter
(`flt-semantics`), ativada automaticamente por `cy.enableSemantics()`.
Text fields aparecem como `<input data-semantics-role="text-field"
aria-label="...">` dentro do no `flt-semantics` — o `cy.fillField()`
preenche esse input. Titulos de AppBar sao `<h2>` reais.

Comandos em `cypress/support/commands.ts`: `openApp`, `enableSemantics`,
`waitForClerk`, `semNode`, `semButton`, `tapButton`, `tapAndWait`,
`openPet`, `fillField`, `clerkUserId`, `sbRest`, `createPetViaApi`,
`createMedicationViaApi`, `createPendingDoseViaApi`,
`createCaregiverViaApi`, `cleanupTestPets`, `emulateReducedMotion`.

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

Os scripts passam por `scripts/cypress.js`, que remove a variavel global
`ELECTRON_RUN_AS_NODE` desta maquina (se presente, o Electron do Cypress
corre como Node e falha com "bad option: --smoke-test").

```bash
cd e2e
npm ci

npm test              # suite Cypress completa (headless)
npm run test:headed   # suite visivel (Electron headed, ritmo lento)
npm run test:open     # Cypress App interativo — escolher "E2E" > "Electron"
npm run test:app      # so a app autenticada
npm run test:fallback # fallback Playwright (sem JS)
npm run test:all      # Cypress + fallback (cross-check)
```

Contra um servidor local:

```bash
SITE_URL=http://localhost:8080 npm test
```

Variaveis: `SITE_URL`, `APP_URL`, `SB_URL`, `SB_ANON_KEY`,
`E2E_EMAIL`, `E2E_PASSWORD`, `AUTH_APP_URL`, `SLOW_MO`,
`E2E_ALLOW_DELETE_ACCOUNT` (aceitam prefixo `CYPRESS_` ou nome direto).

Cypress 16: `Cypress.env()` foi removido. Valores publicos vivem em
`expose:` na config e leem-se com `Cypress.expose()` (sincrono);
`E2E_PASSWORD` fica em `env:` e le-se com `cy.env(['E2E_PASSWORD'])`
(assincrono, fora do browser). Nota: a v16 marca o browser **Electron
como deprecated** — funciona hoje mas sera removido; a alternativa e
Chrome/Edge.

Dados de teste usam nomes `* E2E *` e cada spec apaga os seus no `after`
por prefixo (`Rex E2E`, `MedPet E2E`, `CgVal E2E`, `Foto E2E`, ...).

### Gaps conhecidos (nao existem na app — nao sao bugs de teste)

- Sem "remover pet" (nao ha UI/endpoint de delete de pet)
- Sem "passeios"/walks (feature nunca implementada; removida do marketing)
- Edicao de perfil nao existe fora do onboarding
- Cuidador removido fica visivel na lista com estado "Removido" (soft-delete)

## Cron diario

`.github/workflows/website-e2e.yml` corre todos os dias as 06:17 UTC
(mais `workflow_dispatch` e push em `website/**`/`e2e/**`): Cypress no
Electron via `cypress-io/github-action`, depois o fallback Playwright no
Chrome do sistema.

Notas:
- Rate limiting (429) do subscribe nao e testado no cron para nao poluir
  a waitlist.
- O email `e2e+website@petcare.dev` fica na waitlist (dedup seguro).
