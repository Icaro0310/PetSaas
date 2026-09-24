/// <reference types="cypress" />

// Funcionalidade: Convites para criar conta
//   Cenario: A area principal convida a criar conta ou entrar
//     Dado que um visitante abre a pagina inicial
//     Entao a area principal mostra "Criar conta gratis" e "Entrar"
//     E refere que a aplicacao e gratis
describe('Convites para criar conta', () => {
  it('a área principal tem CTAs de registo e login e diz que é grátis', () => {
    cy.visit('./');
    cy.get('.hero').within(() => {
      cy.contains('a', 'Criar conta grátis').should('be.visible');
      cy.contains('a', 'Entrar na minha conta').should('be.visible');
    });
    cy.get('.hero').should('contain.text', 'grátis');
  });
});
