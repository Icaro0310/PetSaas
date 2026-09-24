/// <reference types="cypress" />

// Funcionalidade: Perfil e conta
//   Cenario: Terminar sessao volta ao ecra de login
//     Dado que estou autenticado na aplicacao
//     Quando escolho "Sair" no perfil
//     Entao volto ao ecra de entrada com "Iniciar sessao"
describe('Perfil e conta', () => {
  it('terminar sessão devolve o ecrã de login', () => {
    cy.openApp();
    cy.tapAndWait('Perfil e conta', { heading: 'Perfil' });
    cy.tapButton('Sair');
    // Clerk signOut redireciona para a base da app -> sem sessao -> login.
    cy.semNode('Iniciar sessão').should('exist');
    cy.semNode('Criar conta grátis').should('exist');
  });
});
