/// <reference types="cypress" />

const SUBSCRIBE = () =>
  `${Cypress.expose('SB_URL')}/functions/v1/subscribe`;

// Funcionalidade: API de subscricao
//   Cenario: Ler o endpoint com GET e rejeitado
//     Dado que um cliente chama a funcao de subscricao com GET
//     Entao recebe "metodo nao permitido" (HTTP 405)
describe('API de subscrição', () => {
  it('um pedido GET é rejeitado com "método não permitido"', () => {
    cy.request({ url: SUBSCRIBE(), failOnStatusCode: false })
      .its('status')
      .should('eq', 405);
  });
});
