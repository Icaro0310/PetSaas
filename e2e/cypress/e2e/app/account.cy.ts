/// <reference types="cypress" />

// DESTRUTIVO: elimina a conta de teste. So corre com E2E_ALLOW_DELETE_ACCOUNT=1
// e APENAS em emails clerk_test — nunca numa conta real.
const email = Cypress.env('E2E_EMAIL') as string;
const allowed =
  Cypress.env('E2E_ALLOW_DELETE_ACCOUNT') === '1' &&
  email.endsWith('+clerk_test@example.com');

const describeDelete = allowed ? describe : describe.skip;

describeDelete('Eliminar conta', () => {
  it('confirma e remove a conta', () => {
    cy.openApp();
    cy.tapAndWait('Perfil e conta', { heading: 'Perfil' });
    cy.tapButton('Eliminar conta');
    cy.tapButton('Eliminar definitivamente');
    // Conta eliminada -> sem sessao -> ecra de login
    cy.semNode('Iniciar sessão').should('exist');
  });
});
