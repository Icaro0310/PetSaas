/// <reference types="cypress" />

const APP_URL = () => Cypress.env('APP_URL') as string;
const APP_LOGIN = () => `${APP_URL()}/login`;

describe('CTAs de conta - o site convida a registar-se', () => {
  it('header tem Entrar + Criar conta grátis', () => {
    cy.visit('./');
    cy.get('.site-nav__links').within(() => {
      cy.get('a')
        .filter((_, el) => (el.textContent ?? '').trim() === 'Entrar')
        .should('be.visible')
        .and('have.attr', 'href', APP_LOGIN());
      cy.contains('a', 'Criar conta grátis')
        .should('be.visible')
        .and('have.attr', 'href', APP_LOGIN());
    });
  });

  it('hero tem CTA de criacao de conta + login', () => {
    cy.visit('./');
    cy.get('.hero').within(() => {
      cy.contains('a', 'Criar conta grátis').should('be.visible');
      cy.contains('a', 'Entrar na minha conta').should('be.visible');
    });
    cy.get('.hero').should('contain.text', 'grátis');
  });

  it('home tem CTA de conta em pelo menos 4 pontos', () => {
    cy.visit('./');
    cy.contains('a', 'Criar conta grátis');
    cy.get('a')
      .filter((_, el) => (el.textContent ?? '').includes('Criar conta grátis'))
      .should('have.length.gte', 4);
  });

  it('faixa CTA intermedia presente e clicavel', () => {
    cy.visit('./');
    cy.get('.cta-strip').scrollIntoView();
    cy.get('.cta-strip').should('contain.text', 'Pronto para começar?');
    cy.get('.cta-strip')
      .contains('a', 'Criar conta grátis')
      .should('be.visible');
  });

  it('clique no CTA abre a app na página de login', () => {
    cy.visit('./');
    cy.get('.hero').contains('a', 'Criar conta grátis').click();
    // GitHub Pages: /PetSaas/app/login -> 404.html -> ?p= -> replaceState.
    cy.location('pathname', { timeout: 30_000 }).should(
      'match',
      /\/PetSaas\/app\/login/,
    );
  });

  it('raiz da app responde 200', () => {
    cy.request(`${APP_URL()}/`).its('status').should('eq', 200);
  });

  it('rota profunda /app/login resolve via fallback 404', () => {
    // Acesso direto a rota SPA: Pages serve 404.html que redireciona
    // para ?p= e a app restaura a URL limpa.
    cy.visit(`${APP_LOGIN()}`, { failOnStatusCode: false });
    cy.location('pathname', { timeout: 30_000 }).should(
      'match',
      /\/PetSaas\/app\/login/,
    );
  });

  it('overlay mobile tem Entrar + Criar conta grátis', () => {
    cy.viewport(390, 844);
    cy.visit('./');
    cy.get('.nav-toggle').click();
    cy.get('#navOverlay').within(() => {
      cy.get('a')
        .filter((_, el) => (el.textContent ?? '').trim() === 'Entrar')
        .should('be.visible');
      cy.contains('a', 'Criar conta grátis').should('be.visible');
    });
  });

  it('nao ha texto de pricing/Premium visivel (app gratuita)', () => {
    for (const path of ['./', 'pricing.html', 'terms.html']) {
      cy.visit(path);
      cy.get('body')
        .invoke('text')
        .should(
          'not.match',
          /premium|1,99|19,99|teste gratis|14 dias de teste|experimentar 14 dias/i,
        );
    }
  });

  it('pricing.html: card Free diz tudo incluido e CTA e criar conta', () => {
    cy.visit('pricing.html');
    cy.get('h1').should('contain.text', 'PetCare é gratuito');
    cy.get('.price-card').within(() => {
      cy.contains('Perfis para vários animais');
      cy.contains('a', 'Criar conta grátis').should('be.visible');
    });
  });
});
