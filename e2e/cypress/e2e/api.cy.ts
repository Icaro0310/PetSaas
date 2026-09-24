/// <reference types="cypress" />

const SB_URL = () => Cypress.env('SB_URL') as string;
const SB_ANON_KEY = () => Cypress.env('SB_ANON_KEY') as string;
const SUBSCRIBE_URL = () => `${SB_URL()}/functions/v1/subscribe`;
const ALLOWED_ORIGIN = () => new URL(Cypress.env('SITE_URL') as string).origin;

const req = (opts: Partial<Cypress.RequestOptions>) =>
  cy.request({ failOnStatusCode: false, ...opts });

describe('Edge Function subscribe - API e seguranca', () => {
  it('OPTIONS preflight devolve 204 com CORS', () => {
    req({
      method: 'OPTIONS',
      url: SUBSCRIBE_URL(),
      headers: { Origin: ALLOWED_ORIGIN() },
    }).then((res) => {
      expect(res.status).to.eq(204);
      expect(res.headers['access-control-allow-origin']).to.exist;
    });
  });

  it('GET nao e permitido (405)', () => {
    req({
      method: 'GET',
      url: SUBSCRIBE_URL(),
      headers: { Origin: ALLOWED_ORIGIN() },
    })
      .its('status')
      .should('eq', 405);
  });

  it('email invalido -> 400', () => {
    req({
      method: 'POST',
      url: SUBSCRIBE_URL(),
      headers: { Origin: ALLOWED_ORIGIN() },
      body: { email: 'invalido' },
    })
      .its('status')
      .should('eq', 400);
  });

  it('payload com campo extra -> 400 (schema strict)', () => {
    req({
      method: 'POST',
      url: SUBSCRIBE_URL(),
      headers: { Origin: ALLOWED_ORIGIN() },
      body: { email: 'e2e+website@petcare.dev', hack: true },
    })
      .its('status')
      .should('eq', 400);
  });

  it('email valido -> 200 success', () => {
    req({
      method: 'POST',
      url: SUBSCRIBE_URL(),
      headers: { Origin: ALLOWED_ORIGIN() },
      body: { email: 'e2e+website@petcare.dev', source: 'e2e' },
    }).then((res) => {
      expect(res.status).to.eq(200);
      expect(res.body.success).to.eq(true);
    });
  });

  it('RLS: anon nao le a waitlist', () => {
    req({
      method: 'GET',
      url: `${SB_URL()}/rest/v1/waitlist?select=*`,
      headers: {
        apikey: SB_ANON_KEY(),
        Authorization: `Bearer ${SB_ANON_KEY()}`,
      },
    }).then((res) => {
      expect(res.status).to.eq(200);
      expect(res.body).to.deep.equal([]); // sem rows visiveis para anon
    });
  });

  it('RLS: anon nao escreve na waitlist', () => {
    req({
      method: 'POST',
      url: `${SB_URL()}/rest/v1/waitlist`,
      headers: {
        apikey: SB_ANON_KEY(),
        Authorization: `Bearer ${SB_ANON_KEY()}`,
        'Content-Type': 'application/json',
      },
      body: { email: 'e2e-anon@petcare.dev' },
    })
      .its('status')
      .should('be.oneOf', [401, 403]);
  });

  it('health Edge Function responde ok', () => {
    cy.request(`${SB_URL()}/functions/v1/health`).then((res) => {
      expect(res.status).to.eq(200);
      expect(res.body.status).to.eq('ok');
    });
  });
});
