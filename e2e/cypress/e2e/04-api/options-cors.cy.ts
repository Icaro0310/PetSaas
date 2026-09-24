/// <reference types="cypress" />

const SUBSCRIBE = () =>
  `${Cypress.env('SB_URL')}/functions/v1/subscribe`;

// Funcionalidade: API de subscricao
//   Cenario: O pedido de permissao do browser e aceite
//     Dado que o browser precisa de autorizacao CORS
//     Quando envia um pedido OPTIONS para a funcao
//     Entao recebe permissao para POST e para o cabecalho Authorization
describe('API de subscrição', () => {
  it('o pedido OPTIONS devolve autorização CORS para POST', () => {
    cy.request({ method: 'OPTIONS', url: SUBSCRIBE(), failOnStatusCode: false })
      .then((res) => {
        expect(res.status).to.be.oneOf([200, 204]);
        expect(res.headers['access-control-allow-methods']).to.include('POST');
        expect(
          res.headers['access-control-allow-headers'],
        ).to.satisfy((h: string) =>
          /authorization|content-type/i.test(h ?? ''),
        );
      });
  });
});
