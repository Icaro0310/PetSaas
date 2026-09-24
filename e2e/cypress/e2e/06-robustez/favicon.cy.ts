/// <reference types="cypress" />

// Funcionalidade: Site resistente a falhas
//   Cenario: O site tem icone no separador do browser
//     Dado que a pagina declara um favicon
//     Entao o ficheiro do icone esta disponivel
describe('Site resistente a falhas', () => {
  it('o favicon declarado está disponível', () => {
    cy.visit('./');
    cy.get('link[rel*="icon"]')
      .first()
      .invoke('attr', 'href')
      .then((href) => {
        expect(href).to.be.a('string').and.not.be.empty;
        cy.request(new URL(href!, Cypress.expose('SITE_URL') + '/').toString())
          .its('status')
          .should('eq', 200);
      });
  });
});
