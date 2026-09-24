/// <reference types="cypress" />

const SITE_URL = () => Cypress.env('SITE_URL') as string;

const PAGES = [
  { path: './', name: 'home' },
  { path: 'pricing.html', name: 'pricing' },
  { path: 'privacy.html', name: 'privacy' },
  { path: 'terms.html', name: 'terms' },
];

describe('Site smoke - paginas carregam corretamente', () => {
  for (const { path, name } of PAGES) {
    it(`${name}: HTTP 200, title, h1 unico, meta description`, () => {
      const errors: string[] = [];
      Cypress.on('uncaught:exception', (e) => {
        errors.push(e.message);
        return false;
      });

      cy.visit(path);
      cy.title().should('match', /PetCare/);
      cy.get('h1').should('have.length', 1);
      cy.get('meta[name="description"]')
        .should('have.attr', 'content')
        .and('match', /.+/);

      cy.wrap(errors).should('deep.equal', []);
    });
  }

  it('assets referenciados na home respondem 200', () => {
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

  it('links internos do site resolvem (sem 404)', () => {
    cy.visit('./');
    cy.document().then((doc) => {
      const hrefs = Array.from(doc.querySelectorAll('a[href]'))
        .map((a) => a.getAttribute('href')!)
        .filter(
          (h) =>
            !h.startsWith('http') && !h.startsWith('mailto:') && !h.startsWith('#'),
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

  it('documentos legais estão marcados como rascunho e não são indexados', () => {
    for (const path of ['terms.html', 'privacy.html']) {
      cy.visit(path);
      cy.get('meta[name="robots"]').should(
        'have.attr',
        'content',
        'noindex,nofollow',
      );
      cy.get('body')
        .invoke('text')
        .should('contain', 'Documento em revisão')
        .and('not.match', /SEU_NOME|SEU_ENDERECO|app\.petcare\.com|legal@petcare\.com/i);
    }
  });
});
