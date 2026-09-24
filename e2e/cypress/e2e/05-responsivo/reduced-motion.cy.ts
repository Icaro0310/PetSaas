/// <reference types="cypress" />

// Funcionalidade: Site em qualquer ecra
//   Cenario: As animacoes respeitam a preferencia de movimento reduzido
//     Dado que um visitante tem "movimento reduzido" ativo no sistema
//     Quando abre a pagina inicial
//     Entao os elementos com animacao de entrada ficam visiveis sem animar
describe('Site em qualquer ecrã', () => {
  it('com movimento reduzido os elementos aparecem sem animação', () => {
    cy.emulateReducedMotion();
    cy.visit('./');
    cy.get('.reveal').first().should('be.visible');
  });
});
