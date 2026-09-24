/// <reference types="cypress" />

// Funcionalidade: Site resistente a falhas
//   Cenario: Com resposta lenta, a UI mostra que esta a enviar
//     Dado que o servidor demora a responder
//     Quando o visitante submete um email valido
//     Entao o botao fica desativado com o texto "A submeter"
//     E a confirmacao aparece quando a resposta chega
describe('Site resistente a falhas', () => {
  it('resposta lenta mostra "A submeter" e depois a confirmação', () => {
    cy.intercept('POST', '**/functions/v1/subscribe', (req) => {
      req.reply({ statusCode: 200, body: { success: true }, delay: 1500 });
    }).as('slowReq');

    cy.visit('./');
    cy.get('[data-subscribe] input[type="email"]')
      .first()
      .type(`cy-slow-${Date.now()}@x.com`);
    cy.get('[data-subscribe] button[type="submit"]').first().as('btn');
    cy.get('@btn').click();
    cy.get('@btn').should('be.disabled').and('contain.text', 'A submeter');
    cy.wait('@slowReq');
    cy.get('.subscribe__msg', { timeout: 15_000 })
      .first()
      .should('contain.text', 'A sua subscrição foi registada');
    cy.get('@btn').should('be.enabled');
  });
});
