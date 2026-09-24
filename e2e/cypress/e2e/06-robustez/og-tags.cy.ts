/// <reference types="cypress" />

// Funcionalidade: Site resistente a falhas
//   Cenario: A pagina tem dados para partilha nas redes sociais
//     Dado que a pagina inicial declara metadados Open Graph
//     Entao titulo, descricao e imagem de partilha estao presentes
describe('Site resistente a falhas', () => {
  it('os metadados Open Graph (título, descrição, imagem) existem', () => {
    cy.visit('./');
    cy.get('meta[property="og:title"]').should('have.attr', 'content');
    cy.get('meta[property="og:description"]').should('have.attr', 'content');
    cy.get('meta[property="og:image"]').should('have.attr', 'content');
  });
});
