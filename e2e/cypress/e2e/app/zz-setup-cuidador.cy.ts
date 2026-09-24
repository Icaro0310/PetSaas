/// <reference types="cypress" />

const CG_EMAIL = 'petcare.e2e.caregiver+clerk_test@example.com';

// Verificacao: a conta de cuidador existe no Clerk?
// NAO pode ser criada programaticamente — o Clerk exige CAPTCHA
// (Cloudflare Turnstile em iframe cross-origin, inacessivel ao Cypress).
// Criacao manual (uma vez): abrir a app, "Criar conta gratis",
// email petcare.e2e.caregiver+clerk_test@example.com, codigo 424242.
// Sem a conta, as specs cuidador-gerir-pets e cuidador-sem-manage-pets
// sao automaticamente skipped.
describe('Setup — conta de cuidador', () => {
  it('verifica se a conta de cuidador existe', function () {
    const appUrl = Cypress.expose('APP_URL') as string;
    cy.visit(`${appUrl}/pets`, { failOnStatusCode: false });
    cy.enableSemantics();
    cy.window().its('Clerk.client', { timeout: 60_000 }).should('exist');
    cy.accountExists(CG_EMAIL).then((exists) => {
      if (!exists) {
        cy.log(
          `SKIP: a conta ${CG_EMAIL} nao existe no Clerk. ` +
            'Cria-a uma vez via UI (Criar conta gratis, codigo 424242).',
        );
        this.skip();
      }
    });
  });
});
