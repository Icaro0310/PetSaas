/// <reference types="cypress" />

describe('Responsividade', () => {
  it('mobile: sem scroll horizontal', () => {
    cy.viewport(390, 844);
    for (const path of ['./', 'pricing.html', 'privacy.html', 'terms.html']) {
      cy.visit(path);
      cy.document().then((doc) => {
        const el = doc.documentElement;
        expect(
          el.scrollWidth,
          `${path} tem overflow horizontal`,
        ).to.be.lte(el.clientWidth + 1);
      });
    }
  });

  it('sem overflow horizontal nos principais breakpoints', () => {
    cy.visit('./');
    for (const width of [320, 375, 414, 768, 1024, 1280, 1920]) {
      cy.viewport(width, 900);
      cy.document().then((doc) => {
        const el = doc.documentElement;
        expect(el.scrollWidth, `overflow a ${width}px`).to.be.lte(
          el.clientWidth + 1,
        );
      });
    }
  });

  it('mobile: menu overlay abre e fecha', () => {
    cy.viewport(390, 844);
    cy.visit('./');

    cy.get('.nav-toggle').as('toggle');
    cy.get('@toggle').should('be.visible').click();

    cy.get('#navOverlay').should('be.visible');
    cy.get('@toggle').should('have.attr', 'aria-expanded', 'true');

    cy.get('.nav-overlay__close').click();
    cy.get('@toggle').should('have.attr', 'aria-expanded', 'false');
  });

  it('desktop: nav links visiveis sem menu hamburger', () => {
    cy.viewport(1440, 900);
    cy.visit('./');
    cy.get('.site-nav__links').should('be.visible');
    cy.get('.nav-toggle').should('not.be.visible');
  });

  it('reduced-motion: conteudo .reveal nunca fica invisivel', () => {
    if (Cypress.browser.family !== 'chromium') {
      cy.log('Emulacao de media so em chromium — skip');
      return;
    }
    cy.emulateReducedMotion();
    cy.visit('./');
    // Com reduced-motion o CSS/JS deve revelar tudo sem animacao
    cy.document().then((doc) => {
      const els = Array.from(doc.querySelectorAll('.reveal'));
      const hidden = els.filter(
        (el) => getComputedStyle(el).opacity === '0',
      ).length;
      expect(hidden).to.eq(0);
    });
  });
});
