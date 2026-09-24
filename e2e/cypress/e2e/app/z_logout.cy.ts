/// <reference types="cypress" />

// Termina a sessao criada pelo openApp — cada teste re-autentica-se,
// por isso o logout nao afeta as outras specs.
describe('Perfil e logout', () => {
  it('pagina de perfil mostra atalhos e acoes', () => {
    cy.openApp();
    cy.tapAndWait('Perfil e conta', { heading: 'Perfil' });
    cy.semNode('Doses de hoje').should('exist');
    cy.semNode('Notificações').should('exist');
    cy.semNode('Sair').should('exist');
    cy.semNode('Eliminar conta').should('exist');
  });

  it('logout volta ao ecra de login', () => {
    cy.openApp();
    cy.tapAndWait('Perfil e conta', { heading: 'Perfil' });
    cy.tapButton('Sair');
    // Clerk signOut redireciona para a base da app -> sem sessao -> login
    cy.semNode('Iniciar sessão').should('exist');
    cy.semNode('Criar conta grátis').should('exist');
  });
});
