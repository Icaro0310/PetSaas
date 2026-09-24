/// <reference types="cypress" />

const AUTH_APP_URL = Cypress.env('AUTH_APP_URL') as string | undefined;

// Funcionalidade: Pagina de login
//   Cenario: O visitante pode alternar para criar conta
//     Dado que a pagina de login esta num servidor local
//     Quando o visitante escolhe "Criar conta"
//     Entao o formulario de registo aparece
const describeAuth = AUTH_APP_URL ? describe : describe.skip;

describeAuth('Página de login (local)', () => {
  it('é possível alternar para o formulário de registo', () => {
    cy.visit(`${AUTH_APP_URL}/login`, { failOnStatusCode: false });
    cy.waitForClerk();
    cy.contains('flt-semantics, .cl-footerActionLink', /[Cc]riar conta/, {
      timeout: 60_000,
    })
      .first()
      .click();
    cy.get('flt-semantics input, .cl-signUp-root input').should('exist');
  });
});
