/// <reference types="cypress" />

// Funcionalidade: Site resistente a falhas
//   Cenario: Se o servidor falhar, a UI mostra mensagem de erro
//     Dado que o servidor responde com erro interno (HTTP 500)
//     Quando o visitante submete um email valido
//     Entao ve uma mensagem de erro compreensivel
//     E o botao volta ao estado normal
describe('Site resistente a falhas', () => {
  it('erro 500 do servidor mostra mensagem e repõe o botão', () => {
    cy.intercept('POST', '**/functions/v1/subscribe', {
      statusCode: 500,
      body: { error: 'internal' },
    });

    cy.visit('./');
    cy.get('[data-subscribe] input[type="email"]')
      .first()
      .type(`cy-500-${Date.now()}@x.com`);
    cy.get('[data-subscribe] button[type="submit"]').first().as('btn');
    cy.get('@btn').click();
    cy.get('.subscribe__msg')
      .first()
      .should('contain.text', 'Não foi possível registar a subscrição');
    cy.get('@btn').should('be.enabled');
  });
});
