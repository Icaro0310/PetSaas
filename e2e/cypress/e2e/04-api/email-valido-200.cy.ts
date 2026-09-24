/// <reference types="cypress" />

const SUBSCRIBE = () =>
  `${Cypress.expose('SB_URL')}/functions/v1/subscribe`;

// Funcionalidade: API de subscricao
//   Cenario: Um email valido e registado
//     Dado que um cliente envia um email valido
//     Entao a API responde sucesso com ok: true
describe('API de subscrição', () => {
  it('um email válido é registado e a API responde ok', () => {
    cy.request('POST', SUBSCRIBE(), {
      email: `cypress-api-${Date.now()}@example.com`,
    }).then((res) => {
      expect(res.status).to.eq(200);
      expect(res.body.success).to.eq(true);
    });
  });
});
