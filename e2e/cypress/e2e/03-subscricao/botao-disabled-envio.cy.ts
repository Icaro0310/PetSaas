/// <reference types="cypress" />

const E2E_EMAIL = 'e2e+website@petcare.dev';

// Funcionalidade: Lista de espera
//   Cenario: O botao fica inativo durante o envio
//     Dado que um visitante submete um email valido
//     Entao o botao fica desativado com o texto "A submeter"
//     E volta ao estado normal quando o envio termina
describe('Lista de espera', () => {
  it('o botão mostra "A submeter" durante o envio e volta ao normal', () => {
    cy.intercept('POST', '**/functions/v1/subscribe', (req) => {
      req.reply({ statusCode: 200, body: { success: true }, delay: 400 });
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
