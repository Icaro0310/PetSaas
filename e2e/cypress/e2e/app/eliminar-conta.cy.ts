/// <reference types="cypress" />

// Funcionalidade: Perfil e conta
//   Cenario: Eliminar definitivamente a conta
//     Dado que estou autenticado com a conta de teste sacrificavel
//     Quando confirmo "Eliminar definitivamente"
//     Entao a conta e removida e volto ao ecra de login
//
// DESTRUTIVO: so corre com E2E_ALLOW_DELETE_ACCOUNT=1 e APENAS em
// emails clerk_test — nunca numa conta real.
const email = Cypress.expose('E2E_EMAIL') as string;
const allowed =
  Cypress.expose('E2E_ALLOW_DELETE_ACCOUNT') === '1' &&
  email.endsWith('+clerk_test@example.com');

const describeDelete = allowed ? describe : describe.skip;

describeDelete('Perfil e conta', () => {
  it('elimina definitivamente a conta de teste', () => {
    cy.openApp();
    cy.tapAndWait('Perfil e conta', { heading: 'Perfil' });
    cy.tapButton('Eliminar conta');
    cy.tapButton('Eliminar definitivamente');
    // Conta eliminada -> sem sessao -> ecra de login.
    cy.semNode('Iniciar sessão').should('exist');
  });
});
