/// <reference types="cypress" />

// Funcionalidade: Site resistente a falhas
//   Cenario: Sem rede, a subscricao mostra erro amigavel
//     Dado que a internet falha no momento do envio
//     Quando o visitante submete um email valido
//     Entao ve a mensagem "Nao foi possivel registar a subscricao"
//     E o botao volta ao estado normal
describe('Site resistente a falhas', () => {
  it('sem rede mostra mensagem de erro sem bloquear a página', () => {
    cy.intercept('POST', '**/functions/v1/subscribe', {
      forceNetworkError: true,
    });

    cy.visit('./');
    cy.get('[data-subscribe] input[type="email"]')
      .first()
      .type(`cy-fail-${Date.now()}@x.com`);
    cy.get('[data-subscribe] button[type="submit"]').first().as('btn');
    cy.get('@btn').click();
    cy.get('.subscribe__msg')
      .first()
      .should('contain.text', 'Não foi possível registar a subscrição');
    cy.get('@btn').should('be.enabled');
  });
});
