/// <reference types="cypress" />

// Funcionalidade: Perfil e conta
//   Cenario: A pagina de perfil mostra os atalhos e acoes
//     Dado que estou autenticado na aplicacao
//     Quando abro "Perfil e conta"
//     Entao vejo os atalhos para doses e notificacoes
//     E as acoes "Sair" e "Eliminar conta"
describe('Perfil e conta', () => {
  it('o perfil mostra atalhos e as ações Sair/Eliminar conta', () => {
    cy.openApp();
    cy.tapAndWait('Perfil e conta', { heading: 'Perfil' });
    cy.semNode('Doses de hoje').should('exist');
    cy.semNode('Notificações').should('exist');
    cy.semNode('Sair').should('exist');
    cy.semNode('Eliminar conta').should('exist');
  });
});
