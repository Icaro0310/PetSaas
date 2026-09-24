/// <reference types="cypress" />

const SUBSCRIBE = () =>
  `${Cypress.expose('SB_URL')}/functions/v1/subscribe`;

// Funcionalidade: API de subscricao
//   Cenario: Um email invalido e rejeitado pela API
//     Dado que um cliente envia um email sem formato valido
//     Entao a API responde erro 400 com o motivo
describe('API de subscrição', () => {
  it('um email inválido é rejeitado com erro 400 e o motivo', () => {
    cy.request({
      method: 'POST',
      url: SUBSCRIBE(),
      body: { email: 'not-an-email' },
      failOnStatusCode: false,
    }).then((res) => {
      expect(res.status).to.eq(400);
      expect(res.body).to.have.property('error');
    });
  });
});
