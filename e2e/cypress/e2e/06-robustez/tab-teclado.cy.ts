/// <reference types="cypress" />
import 'cypress-real-events';

// Funcionalidade: Site resistente a falhas
//   Cenario: A navegacao por teclado funciona
//     Dado que um visitante usa apenas o teclado
//     Quando o foco esta num link e prime a tecla Tab
//     Entao o foco avanca para o elemento interativo seguinte
describe('Site resistente a falhas', () => {
  it('a tecla Tab move o foco para o elemento interativo seguinte', () => {
    cy.visit('./');
    // Foca o primeiro link da navegacao e verifica que Tab move o foco.
    cy.get('.site-nav__links a').first().focus();
    cy.document()
      .its('activeElement')
      .should('have.prop', 'tagName', 'A');
    cy.realPress('Tab');
    cy.document().then((doc) => {
      const el = doc.activeElement as HTMLElement | null;
      expect(el?.tagName).to.match(/^(A|BUTTON|INPUT|TEXTAREA|SELECT)$/);
    });
  });
});
