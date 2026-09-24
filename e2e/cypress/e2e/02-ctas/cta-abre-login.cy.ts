/// <reference types="cypress" />

// Funcionalidade: Convites para criar conta
//   Cenario: Clicar no CTA leva a pagina de login da aplicacao
//     Dado que um visitante esta na pagina inicial
//     Quando clica em "Criar conta gratis"
//     Entao a aplicacao abre na pagina de login
describe('Convites para criar conta', () => {
  it('clicar no CTA abre a aplicação na página de login', () => {
    cy.visit('./');
    cy.get('.hero').contains('a', 'Criar conta grátis').click();
    // GitHub Pages: /PetSaas/app/login -> 404.html -> ?p= -> replaceState.
    cy.location('pathname', { timeout: 30_000 }).should(
      'match',
      /\/PetSaas\/app\/login/,
    );
  });
});
