/// <reference types="cypress" />

const E2E_EMAIL = 'e2e+website@petcare.dev';

// Funcionalidade: Lista de espera
//   Cenario: O botao fica inativo durante o envio
//     Dado que um visitante submete um email valido
//     Entao o botao fica desativado com o texto "A submeter"
//     E volta ao estado normal quando o envio termina
describe('Lista de espera', () => {
  it('o botão mostra "A submeter" durante o envio e volta ao normal', () => {
    // A janela "A submeter" tem de durar mais que a pausa SLOW_MO
    // (~900ms em modo visivel) — senao o botao volta ao normal antes
    // da assercao correr.
    const delayMs = 1500 + Number(Cypress.expose('SLOW_MO') ?? 0) * 2;
    cy.intercept('POST', '**/functions/v1/subscribe', (req) => {
      req.reply({ statusCode: 200, body: { success: true }, delay: delayMs });
    }).as('subscribe');

    cy.visit('./');
    cy.get('[data-subscribe] input[type="email"]').first().type(E2E_EMAIL);
    cy.get('[data-subscribe] button[type="submit"]').first().as('btn');
    cy.get('@btn').click();
    cy.get('@btn').should('be.disabled').and('contain.text', 'A submeter');
    cy.wait('@subscribe');
    cy.get('@btn').should('not.be.disabled');
  });
});
