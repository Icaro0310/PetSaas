/// <reference types="cypress" />

const AUTH_APP_URL = Cypress.expose('AUTH_APP_URL') as string | undefined;

// Funcionalidade: Pagina de login
//   Cenario: O formulario de entrada aparece
//     Dado que a pagina de login esta num servidor local
//     Entao o visitante ve o formulario para introduzir o email
const describeAuth = AUTH_APP_URL ? describe : describe.skip;

describeAuth('Página de login (local)', () => {
  it('o formulário de entrada fica visível', () => {
    cy.visit(`${AUTH_APP_URL}/login`, { failOnStatusCode: false });
    cy.waitForClerk();
    cy.get('flt-semantics input, .cl-signIn-root input', {
      timeout: 60_000,
    }).should('exist');
  });
});
