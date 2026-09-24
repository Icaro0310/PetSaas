/// <reference types="cypress" />

// Email dedicado aos testes E2E — deduplicado na waitlist apos o 1o
// insert, por isso este teste nao consome o rate limit (5/hora por IP).
const E2E_EMAIL = 'e2e+website@petcare.dev';

// Funcionalidade: Lista de espera
//   Cenario: Um email valido e aceite
//     Dado que um visitante esta na pagina inicial
//     Quando escreve um email valido e submete
//     Entao ve a confirmacao de subscricao
//     E o campo e limpo
describe('Lista de espera', () => {
  it('um email válido é aceite e mostra confirmação', () => {
    cy.visit('./');
    cy.get('[data-subscribe] input[type="email"]').first().as('input');
    cy.get('@input').type(E2E_EMAIL);
    cy.get('[data-subscribe] button[type="submit"]').first().click();
    cy.get('.subscribe__msg', { timeout: 15_000 })
      .first()
      .should('contain.text', 'A sua subscrição foi registada');
    cy.get('@input').should('have.value', '');
  });
});
