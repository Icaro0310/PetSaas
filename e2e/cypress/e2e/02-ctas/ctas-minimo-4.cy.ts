/// <reference types="cypress" />

// Funcionalidade: Convites para criar conta
//   Cenario: A pagina convida a registar-se em varios pontos
//     Dado que um visitante abre a pagina inicial
//     Entao encontra "Criar conta gratis" em pelo menos 4 locais
describe('Convites para criar conta', () => {
  it('a página tem "Criar conta grátis" em pelo menos 4 pontos', () => {
    cy.visit('./');
    cy.get('a')
      .filter((_, el) => (el.textContent ?? '').includes('Criar conta grátis'))
      .should('have.length.gte', 4);
  });
});
