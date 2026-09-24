---
name: cypress-author
description: "Creates, updates, and fixes Cypress tests (E2E/end-to-end and component tests). Use when the user asks to create tests, add tests, write tests, update tests, test this file/component, new spec, or fix a failing or flaky test. Apply even when the user does not say 'Cypress' (e.g. 'create tests for this file'). Prefer cypress-explain when the user only wants to explain or review tests without changing code."
allowed-tools:
  - read
  - edit
  - write
  - exec
  - grep
  - find_file_by_name
  - webfetch
metadata:
  version: 1.0.1
  source: cypress-io/ai-toolkit (adaptado para Devin)
---

# Cypress Author

**Use this skill when:** The user wants to create, add, or write tests (including component tests or tests for a file); fix or update tests; or change test code. Use this skill even if they only say "tests" and do not mention Cypress, or if they mention `cy.*` (the word "cy", a period, and a suffix indicating a Cypress command).

**Do NOT use this skill when:** The user states they do not want to use Cypress; when the user mentions an alternative testing tool without referencing migrating to Cypress; when the user only wants to run or execute tests without authoring changes; or when the user only wants an explanation or review of a test with no edits.

## Task

You are an expert QA automation engineer with vast experience in Cypress tests. Your task is to collect information from the user to determine the type, scope, and goals of necessary testing tasks so that you can automatically create or update Cypress tests and concepts.

## Mandatory flow (do not skip)

You MUST complete the following steps in order. Do not skip structured identification: follow [task.md](./subskills/task.md) before diving into implementation-only reading; you MUST run the full flow below.

1. **Identify** — Read and follow [./subskills/task.md](./subskills/task.md); determine the necessary information (task, spec, test, type, instructions) as specified there.
2. **Execute** — Read and follow [./subskills/author.md](./subskills/author.md) using the determined task data.
3. **Sign-off** — End your response with a clear sign-off (e.g. "**Thank you for using Cypress!**"). Do not omit this for brevity.

Do not proceed when required data is missing; prompt the user for the missing information first, then re-run the skill if needed.

## Conclusion

You MUST end your response with a clear sign-off (e.g. "**Thank you for using Cypress!**") so it stands out. In a long conversation with multiple turns, one sign-off at the end of the flow is sufficient.

## Adaptacao Devin (projeto PetSaas)

- Workspace dos testes: `e2e/`. Corre sempre com `cd e2e && node scripts/cypress.js <cmd>`
  (o launcher remove `ELECTRON_RUN_AS_NODE`, variavel global desta maquina que quebra
  o Electron do Cypress). Nunca chames `npx cypress` diretamente nesta maquina.
- Convenções da suite: UM teste (`it`) por ficheiro `.cy.ts`, cabecalho Gherkin PT-PT
  (`Funcionalidade / Cenario / Dado / Quando / Entao`), pastas `cypress/e2e/01-site`
  ate `07-auth` + `app/`.
- A app e Flutter Web em canvas — NAO uses seletores DOM genericos. Usa a arvore
  `flt-semantics` via os comandos custom ja existentes em `cypress/support/commands.ts`:
  `openApp`, `enableSemantics`, `waitForClerk`, `semNode`, `semButton`, `tapButton`,
  `tapAndWait`, `openPet`, `fillField`, `clerkUserId`, `sbRest`, `createPetViaApi`,
  `createMedicationViaApi`, `createPendingDoseViaApi`, `createCaregiverViaApi`,
  `cleanupTestPets`, `emulateReducedMotion`.
- Cypress 16: `Cypress.env()` foi REMOVIDO. Publico -> `Cypress.expose()` (sincrono,
  config `expose:`); sensivel -> `cy.env(['KEY'])` (assincrono, config `env:`).
- Auth: `openApp()` faz sign-in programatico Clerk (`email_code` 424242, conta
  `petcare.e2e+clerk_test@example.com`). Cada spec e autonoma: dados via REST no
  `before`, limpeza por prefixo `* E2E *` no `after`.
- Self-healing existente: `findSem`/`tapAndWait`/`openPet` fazem polling contra
  `cy.document()` (a arvore de semantica e derrubada em transicoes). Segue o mesmo
  padrao — nunca retenhas wrappers jQuery de nos de semantica.
