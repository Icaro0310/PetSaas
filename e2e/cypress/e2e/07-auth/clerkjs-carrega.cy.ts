/// <reference types="cypress" />

const AUTH_APP_URL = Cypress.env('AUTH_APP_URL') as string | undefined;

// Funcionalidade: Pagina de login
//   Cenario: O sistema de autenticacao carrega
//     Dado que a pagina de login esta num servidor local
//     Entao o componente de autenticacao (Clerk) fica disponivel
// Nota: corre apenas com AUTH_APP_URL definido (instancia local da app).
const describeAuth = AUTH_APP_URL ? describe : describe.skip;

describeAuth('Página de login (local)', () => {
  it('o componente de autenticação (Clerk) carrega', () => {
    cy.visit(`${AUTH_APP_URL}/login`, { failOnStatusCode: false });
    cy.waitForClerk();
  });
});
