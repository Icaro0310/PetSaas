/// <reference types="cypress" />

// Funcionalidade: Website publico PetCare
//   Cenario: A pagina inicial carrega corretamente
//     Dado que um visitante abre a pagina inicial
//     Entao o titulo, o cabecalho principal e a descricao estao corretos
//     E nao ocorrem erros de JavaScript
describe('Website publico', () => {
  it('a página inicial carrega com título, cabeçalho e descrição sem erros', () => {
    const errors: string[] = [];
    Cypress.on('uncaught:exception', (e) => {
      errors.push(e.message);
      return false;
    });

    cy.visit('./');
    cy.title().should('match', /PetCare/);
    cy.get('h1').should('have.length', 1);
    cy.get('meta[name="description"]')
      .should('have.attr', 'content')
      .and('match', /.+/);
    cy.wrap(errors).should('deep.equal', []);
  });
});
