/// <reference types="cypress" />

const SITE_URL = () => Cypress.env('SITE_URL') as string;
const SUBSCRIBE_URL = () =>
  `${Cypress.env('SB_URL')}/functions/v1/subscribe`;

// Suite de fragilidade UAT: falhas de rede, teclado, a11y, assets.
// O teste "sem JavaScript" fica no fallback Playwright (tests-fallback/) —
// o Cypress injeta-se na pagina e nao consegue correr com JS desligado.
describe('Robustez UAT - cenarios de falha e acessibilidade', () => {
  it('rede em baixo: erro visivel e botao reabilitado', () => {
    cy.intercept(SUBSCRIBE_URL(), { forceNetworkError: true });
    cy.visit('./');
    cy.get('[data-subscribe]').first().within(() => {
      cy.get('input[type="email"]').type('falha@example.com');
      cy.get('button[type="submit"]').click();
    });
    cy.get('.subscribe__msg')
      .first()
      .should('contain.text', 'Não foi possível');
    cy.get('[data-subscribe] button[type="submit"]')
      .first()
      .should('be.enabled');
  });

  it('resposta lenta: botao fica disabled e recupera no fim', () => {
    cy.intercept(SUBSCRIBE_URL(), (req) => {
      req.reply({ statusCode: 200, body: { success: true }, delay: 1200 });
    });
    cy.visit('./');
    cy.get('[data-subscribe] input[type="email"]')
      .first()
      .type('lento@example.com');
    cy.get('[data-subscribe] button[type="submit"]').first().as('btn');
    cy.get('@btn').click();
    cy.get('@btn').should('be.disabled');
    cy.get('.subscribe__msg', { timeout: 10_000 })
      .first()
      .should('contain.text', 'A sua subscrição foi registada');
    cy.get('@btn').should('be.enabled');
  });

  it('resposta 500 do servidor: erro generico, sem crash', () => {
    cy.intercept(SUBSCRIBE_URL(), {
      statusCode: 500,
      body: { error: 'internal' },
    });
    cy.visit('./');
    cy.get('[data-subscribe] input[type="email"]')
      .first()
      .type('erro@example.com');
    cy.get('[data-subscribe] button[type="submit"]').first().click();
    cy.get('.subscribe__msg')
      .first()
      .should('contain.text', 'Não foi possível');
  });

  it('Escape fecha o overlay mobile', () => {
    cy.viewport(390, 844);
    cy.visit('./');
    cy.get('.nav-toggle').click();
    cy.get('#navOverlay').should('be.visible');
    cy.get('body').realPress('Escape');
    cy.get('.nav-toggle').should('have.attr', 'aria-expanded', 'false');
  });

  it('teclado: Tab alcanca links de navegacao', () => {
    cy.visit('./');
    cy.get('body').realPress('Tab');
    cy.focused()
      .invoke('prop', 'tagName')
      .should('be.oneOf', ['A', 'BUTTON']);
  });

  it('email invalido marca aria-invalid no input', () => {
    cy.visit('./');
    cy.get('[data-subscribe]').first().within(() => {
      cy.get('input[type="email"]').type('nao-e-email');
      cy.get('button[type="submit"]').click();
    });
    cy.get('[data-subscribe] input[type="email"]')
      .first()
      .should('have.attr', 'aria-invalid', 'true');
  });

  it('mensagem de estado usa regiao aria-live', () => {
    cy.visit('./');
    cy.get('.subscribe__msg')
      .first()
      .should('have.attr', 'aria-live', 'polite');
  });

  it('pagina inexistente devolve 404', () => {
    cy.request({
      url: `${SITE_URL()}/pagina-que-nao-existe-${Date.now()}.html`,
      failOnStatusCode: false,
    })
      .its('status')
      .should('eq', 404);
  });

  it('favicon carrega', () => {
    cy.request(`${SITE_URL()}/assets/favicon.png`)
      .its('status')
      .should('eq', 200);
  });

  it('todas as imagens tem alt', () => {
    cy.visit('./');
    cy.document().then((doc) => {
      const missing = Array.from(doc.querySelectorAll('img'))
        .filter((img) => !img.hasAttribute('alt'))
        .map((img) => img.getAttribute('src'));
      expect(missing).to.deep.equal([]);
    });
  });

  it('links externos com _blank tem rel=noopener', () => {
    cy.visit('./');
    cy.document().then((doc) => {
      const unsafe = Array.from(doc.querySelectorAll('a[target="_blank"]'))
        .filter((a) => !(a.getAttribute('rel') || '').includes('noopener'))
        .map((a) => a.getAttribute('href'));
      expect(unsafe).to.deep.equal([]);
    });
  });

  it('OG tags essenciais presentes e og:image absoluto', () => {
    cy.visit('./');
    cy.get('meta[property="og:title"]')
      .invoke('attr', 'content')
      .should('have.length.gt', 0);
    cy.get('meta[property="og:description"]')
      .invoke('attr', 'content')
      .should('have.length.gt', 0);
    cy.get('meta[property="og:image"]')
      .invoke('attr', 'content')
      .should('match', /^https:\/\//);
  });
});
