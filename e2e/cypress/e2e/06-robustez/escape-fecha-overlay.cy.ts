/// <reference types="cypress" />
import 'cypress-real-events';

// Funcionalidade: Site resistente a falhas
//   Cenario: A tecla Escape fecha o menu mobile
//     Dado que o menu mobile esta aberto
//     Quando o visitante prime a tecla Escape
//     Entao o menu fecha
describe('Site resistente a falhas', () => {
  it('a tecla Escape fecha o menu mobile', () => {
    cy.viewport(390, 844);
    cy.visit('./');
    cy.get('.nav-toggle').click();
    cy.get('#navOverlay').should('be.visible');
    cy.get('body').realPress('Escape');
    cy.get('#navOverlay').should('not.be.visible');
  });
});
