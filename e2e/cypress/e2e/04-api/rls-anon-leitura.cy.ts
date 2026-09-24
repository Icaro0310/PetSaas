/// <reference types="cypress" />

const SB = () => Cypress.expose('SB_URL') as string;
const KEY = () => Cypress.expose('SB_ANON_KEY') as string;

// Funcionalidade: API de subscricao
//   Cenario: A lista de emails nao expoe dados a anonimos
//     Dado que um utilizador anonimo tenta ler a tabela waitlist
//     Entao a regra de seguranca (RLS) devolve uma lista vazia
//     E nenhum email e exposto
describe('API de subscrição', () => {
  it('a leitura anónima da tabela de emails não devolve dados (RLS)', () => {
    cy.request({
      url: `${SB()}/rest/v1/waitlist?select=id,email`,
      headers: { apikey: KEY() },
      failOnStatusCode: false,
    }).then((res) => {
      // RLS do PostgREST para SELECT nao devolve erro — devolve 200 com
      // as linhas que a policy permite. A policy nega tudo a anonimos,
      // por isso a lista tem de vir vazia (zero exposicao de emails).
      expect(res.status).to.eq(200);
      expect(res.body).to.deep.eq([]);
    });
  });
});
