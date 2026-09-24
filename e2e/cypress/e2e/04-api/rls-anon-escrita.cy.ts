/// <reference types="cypress" />

const SB = () => Cypress.expose('SB_URL') as string;
const KEY = () => Cypress.expose('SB_ANON_KEY') as string;

// Funcionalidade: API de subscricao
//   Cenario: A tabela de emails nao aceita escrita direta anonima
//     Dado que um utilizador anonimo tenta escrever diretamente na tabela
//     Entao a regra de seguranca impede a escrita (HTTP 401/403/404)
describe('API de subscrição', () => {
  it('a tabela de emails não aceita escrita direta sem autenticação', () => {
    cy.request({
      method: 'POST',
      url: `${SB()}/rest/v1/waitlist`,
      headers: {
        apikey: KEY(),
        Authorization: `Bearer ${KEY()}`,
        'Content-Type': 'application/json',
      },
      body: { email: 'x@x.com' },
      failOnStatusCode: false,
    })
      .its('status')
      .should('be.oneOf', [401, 403, 404]);
  });
});
