/// <reference types="cypress" />

// DEBUG temporario: mede se o JWT Clerk passa no /auth/v1/user do GoTrue.
// Nao imprime o token — apenas status, iss/aud do payload e o body de erro.

const SB_URL = Cypress.expose('SB_URL') as string;
const ANON = Cypress.expose('SB_ANON_KEY') as string;

describe('dbg auth', () => {
  it('getUser com Clerk JWT', () => {
    cy.openApp();
    cy.window().then(async (win: any) => {
      const out: Record<string, unknown> = {};
      let jwt: string;
      try {
        jwt = await win.Clerk.session.getToken({ template: 'supabase' });
        out.template = 'supabase-ok';
      } catch (e: any) {
        out.template = `falhou: ${String(e).slice(0, 120)}`;
        jwt = await win.Clerk.session.getToken();
      }
      const payload = JSON.parse(
        atob(jwt.split('.')[1].replace(/-/g, '+').replace(/_/g, '/')),
      );
      out.iss = payload.iss;
      out.aud = payload.aud;
      out.sub = payload.sub;
      out.exp_soon = payload.exp - Math.floor(Date.now() / 1000);

      const r = await fetch(`${SB_URL}/auth/v1/user`, {
        headers: { apikey: ANON, Authorization: `Bearer ${jwt}` },
      });
      out.authUserStatus = r.status;
      out.authUserBody = (await r.text()).slice(0, 300);

      const rf = await fetch(`${SB_URL}/functions/v1/petdesk-generate`, {
        method: 'POST',
        headers: {
          apikey: ANON,
          Authorization: `Bearer ${jwt}`,
          'content-type': 'application/json',
        },
        body: JSON.stringify({ kind: 'nao-existe' }),
      });
      out.fnStatus = rf.status;
      out.fnBody = (await rf.text()).slice(0, 300);

      cy.writeFile('cypress/dbg-auth.json', out);
    });
  });
});
