/// <reference types="cypress" />

// Funcionalidade: Convites para criar conta
//   Cenario: A aplicacao web esta no ar
//     Dado que a aplicacao esta publicada
//     Entao a raiz da aplicacao responde com sucesso (HTTP 200)
describe('Convites para criar conta', () => {
  it('a raiz da aplicação responde com sucesso', () => {
    cy.request(`${Cypress.env('APP_URL')}/`)
      .its('status')
      .should('eq', 200);
  });
});
