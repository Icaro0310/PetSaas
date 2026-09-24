/// <reference types="cypress" />

// Funcionalidade: Convites para criar conta
//   Cenario: O menu mobile convida a entrar ou registar
//     Dado que um visitante abre a pagina inicial num telemovel
//     Quando abre o menu
//     Entao ve os links "Entrar" e "Criar conta gratis"
describe('Convites para criar conta', () => {
  it('o menu mobile mostra "Entrar" e "Criar conta grátis"', () => {
    cy.viewport(390, 844);
    cy.visit('./');
    cy.get('.nav-toggle').click();
    cy.get('#navOverlay').within(() => {
      cy.get('a')
        .filter((_, el) => (el.textContent ?? '').trim() === 'Entrar')
        .should('be.visible');
      cy.contains('a', 'Criar conta grátis').should('be.visible');
    });
  });
});
