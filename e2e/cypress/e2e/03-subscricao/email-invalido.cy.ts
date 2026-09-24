/// <reference types="cypress" />

// Funcionalidade: Lista de espera
//   Cenario: Um email invalido e rejeitado
//     Dado que um visitante esta na pagina inicial
//     Quando escreve um email sem formato valido e submete
//     Entao ve a mensagem de erro de email invalido
//     E o campo fica marcado como invalido
describe('Lista de espera', () => {
  it('um email inválido mostra erro e marca o campo', () => {
    cy.visit('./');
    cy.get('[data-subscribe] input[type="email"]').first().as('input');
    cy.get('@input').type('not-an-email');
    cy.get('[data-subscribe] button[type="submit"]').first().click();
    cy.get('.subscribe__msg')
      .first()
      .should('contain.text', 'endereço de email válido');
    cy.get('@input').should('have.attr', 'aria-invalid', 'true');
  });
});
