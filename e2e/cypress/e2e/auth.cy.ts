/// <reference types="cypress" />

// Corre apenas contra um build Web local: define AUTH_APP_URL para ativar.
const AUTH_APP_URL = Cypress.env('AUTH_APP_URL') as string | null;
const APP_BASE = AUTH_APP_URL
  ? AUTH_APP_URL.endsWith('/')
    ? AUTH_APP_URL
    : `${AUTH_APP_URL}/`
  : null;

const describeAuth = APP_BASE ? describe : describe.skip;

describeAuth('Autenticação Clerk na Web', () => {
  it('carrega o ClerkJS e apresenta as ações de conta', () => {
    cy.visit(APP_BASE!);
    cy.location('pathname', { timeout: 30_000 }).should('match', /\/login$/);
    cy.semButton('Iniciar sessão').should('exist');
    cy.semButton('Criar conta grátis').should('exist');
    cy.window()
      .its('PetCareClerkReady', { timeout: 30_000 })
      .then(async (ready: any) => {
        const api = await ready;
        expect(await api.getUser()).to.eq('null');
      });
  });

  it('abre o formulário de início de sessão do Clerk', () => {
    cy.visit(APP_BASE!);
    cy.location('pathname', { timeout: 30_000 }).should('match', /\/login$/);
    cy.enableSemantics();
    cy.tapButton('Iniciar sessão');
    cy.contains('label', 'Endereço de email', { timeout: 20_000 }).should(
      'be.visible',
    );
  });

  it('abre o formulário de criação de conta do Clerk', () => {
    cy.visit(APP_BASE!);
    cy.location('pathname', { timeout: 30_000 }).should('match', /\/login$/);
    cy.enableSemantics();
    cy.tapButton('Criar conta grátis');
    cy.contains('label', 'Endereço de email', { timeout: 20_000 }).should(
      'be.visible',
    );
  });
});
