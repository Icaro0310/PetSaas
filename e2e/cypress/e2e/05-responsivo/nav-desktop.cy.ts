/// <reference types="cypress" />

// Funcionalidade: Site em qualquer ecra
//   Cenario: No desktop a navegacao esta sempre visivel
//     Dado que um visitante abre a pagina inicial num ecra grande
//     Entao a navegacao esta visivel sem menu de hamburguer
describe('Site em qualquer ecrã', () => {
  it('no desktop a navegação está visível e o hambúrguer escondido', () => {
    cy.viewport(1280, 900);
    cy.visit('./');
    cy.get('.site-nav__links').should('be.visible');
    cy.get('.nav-toggle').should('not.be.visible');
  });
});
