/// <reference types="cypress" />

// Funcionalidade: Site resistente a falhas
//   Cenario: As mensagens de estado sao anunciadas a leitores de ecra
//     Dado que a pagina tem uma area de mensagens de subscricao
//     Entao essa area usa a tecnica "aria-live" para anunciar mudancas
describe('Site resistente a falhas', () => {
  it('a área de mensagens usa aria-live para leitores de ecrã', () => {
    cy.visit('./');
    cy.get('.subscribe__msg').first().should('have.attr', 'aria-live');
  });
});
