/// <reference types="cypress" />

const SITE_URL = () => Cypress.env('SITE_URL') as string;

// Funcionalidade: Website publico PetCare
//   Cenario: Os links internos do site funcionam
//     Dado que um visitante abre a pagina inicial
//     Quando segue qualquer link interno
//     Entao nenhuma pagina devolve erro 404
describe('Website publico', () => {
  it('todos os links internos resolvem sem erro 404', () => {
    cy.visit('./');
    cy.document().then((doc) => {
      const hrefs = Array.from(doc.querySelectorAll('a[href]'))
        .map((a) => a.getAttribute('href')!)
        .filter(
          (h) =>
            !h.startsWith('http') &&
            !h.startsWith('mailto:') &&
            !h.startsWith('#'),
        );
      const unique = [...new Set(hrefs)];
      for (const h of unique) {
        cy.request({
          url: new URL(h, SITE_URL() + '/').toString(),
          failOnStatusCode: false,
        })
          .its('status')
          .should('eq', 200);
      }
    });
  });
});
