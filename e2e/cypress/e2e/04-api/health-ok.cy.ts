/// <reference types="cypress" />

// Funcionalidade: API de subscricao
//   Cenario: A funcao de saude responde que esta no ar
//     Dado que alguem chama o endpoint de saude
//     Entao recebe status "ok"
describe('API de subscrição', () => {
  it('o endpoint de saúde responde ok', () => {
    cy.request(
      `${Cypress.env('SB_URL')}/functions/v1/health`,
    ).then((res) => {
      expect(res.body.status).to.eq('ok');
    });
  });
});
