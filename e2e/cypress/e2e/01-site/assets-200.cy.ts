/// <reference types="cypress" />

const SITE_URL = () => Cypress.env('SITE_URL') as string;

// Funcionalidade: Website publico PetCare
//   Cenario: Todos os recursos da pagina inicial estao disponiveis
//     Dado que um visitante abre a pagina inicial
//     Quando o browser pede imagens, scripts e folhas de estilo
//     Entao todos os recursos respondem com sucesso (HTTP 200)
describe('Website publico', () => {
  it('todos os recursos da página inicial respondem com sucesso', () => {
    cy.visit('./');
    cy.document().then((doc) => {
      const urls: string[] = [];
      doc
        .querySelectorAll('img[src], script[src], link[rel="stylesheet"][href]')
        .forEach((el) => {
          const u = el.getAttribute('src') ?? el.getAttribute('href');
          if (u && !u.startsWith('data:')) urls.push(u);
        });
      expect(urls.length).to.be.greaterThan(0);
      for (const u of urls) {
        cy.request(new URL(u, SITE_URL() + '/').toString())
          .its('status')
          .should('eq', 200);
      }
    });
  });
});
