/// <reference types="cypress" />

const SUBSCRIBE = () =>
  `${Cypress.env('SB_URL')}/functions/v1/subscribe`;

// Funcionalidade: API de subscricao
//   Cenario: Campos extra sao rejeitados
//     Dado que um cliente envia um email valido com campos a mais
//     Entao a API responde erro 400 (schema rigido)
describe('API de subscrição', () => {
  it('um payload com campos extra é rejeitado com erro 400', () => {
    cy.request({
      method: 'POST',
      url: SUBSCRIBE(),
      body: { email: `cy-schema-${Date.now()}@x.com`, extra: 'nope' },
      failOnStatusCode: false,
    })
      .its('status')
      .should('eq', 400);
  });
});
