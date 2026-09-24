/// <reference types="cypress" />

// Funcionalidade: Site resistente a falhas
//   Cenario: O campo de email e marcado como invalido
//     Dado que um visitante submete um email com formato errado
//     Entao o campo fica com a marca de acessibilidade "invalido"
describe('Site resistente a falhas', () => {
  it('email inválido marca o campo com aria-invalid', () => {
    cy.visit('./');
    cy.get('[data-subscribe] input[type="email"]').first().type('bad-email');
    cy.get('[data-subscribe] button[type="submit"]').first().click();
    cy.get('[data-subscribe] input[type="email"]')
      .first()
      .should('have.attr', 'aria-invalid', 'true');
  });
});
