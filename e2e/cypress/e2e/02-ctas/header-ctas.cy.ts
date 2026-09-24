/// <reference types="cypress" />

const APP_LOGIN = () => `${Cypress.expose('APP_URL')}/login`;

// Funcionalidade: Convites para criar conta
//   Cenario: O cabecalho convida a entrar ou registar
//     Dado que um visitante abre a pagina inicial em desktop
//     Entao ve os links "Entrar" e "Criar conta gratis"
//     E ambos apontam para a pagina de login da aplicacao
describe('Convites para criar conta', () => {
  it('o cabeçalho mostra "Entrar" e "Criar conta grátis" para a app', () => {
    cy.visit('./');
    cy.get('.site-nav__links').within(() => {
      cy.get('a')
        .filter((_, el) => (el.textContent ?? '').trim() === 'Entrar')
        .should('be.visible')
        .and('have.attr', 'href', APP_LOGIN());
      cy.contains('a', 'Criar conta grátis')
        .should('be.visible')
        .and('have.attr', 'href', APP_LOGIN());
    });
  });
});
