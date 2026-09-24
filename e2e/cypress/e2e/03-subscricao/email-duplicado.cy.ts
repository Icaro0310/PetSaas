/// <reference types="cypress" />

// Email dedicado — ja subscrito; a funcao devolve success silencioso
// (dedup) para nao revelar se um email existe na lista.
const E2E_EMAIL = 'e2e+website@petcare.dev';
const SUBSCRIBE = () =>
  `${Cypress.expose('SB_URL')}/functions/v1/subscribe`;

// Funcionalidade: Lista de espera
//   Cenario: Um email repetido nao mostra erro
//     Dado que um email ja esta subscrito
//     Quando o visitante submete o mesmo email outra vez
//     Entao ve a mesma mensagem de sucesso (deduplicacao silenciosa)
describe('Lista de espera', () => {
  it('um email repetido mostra a mesma mensagem de sucesso (dedup)', () => {
    // Garante que o email existe na waitlist (dedup -> sem custo de
    // rate limit e sem email de boas-vindas repetido).
    cy.request('POST', SUBSCRIBE(), { email: E2E_EMAIL })
      .its('status')
      .should('eq', 200);

    cy.visit('./');
    cy.get('[data-subscribe] input[type="email"]').first().type(E2E_EMAIL);
    cy.get('[data-subscribe] button[type="submit"]').first().click();
    cy.get('.subscribe__msg', { timeout: 15_000 })
      .first()
      .should('contain.text', 'A sua subscrição foi registada');
  });
});
