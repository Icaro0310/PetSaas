/// <reference types="cypress" />

// Funcionalidade: Site em qualquer ecra
//   Cenario: O menu de navegacao abre e fecha no telemovel
//     Dado que um visitante abre a pagina inicial num telemovel
//     Quando toca no botao do menu
//     Entao o painel de navegacao aparece
//     E desaparece quando volta a tocar
describe('Site em qualquer ecrã', () => {
  it('o menu mobile abre e fecha com o botão', () => {
    cy.viewport(390, 844);
    cy.visit('./');
    cy.get('.nav-toggle').should('be.visible').click();
    cy.get('#navOverlay').should('be.visible');
    cy.get('.nav-overlay__close').click();
    cy.get('#navOverlay').should('not.be.visible');
  });
});
