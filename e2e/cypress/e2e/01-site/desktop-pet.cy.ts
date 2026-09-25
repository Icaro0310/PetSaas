/// <reference types="cypress" />

// Funcionalidade: Pagina Desktop Pet (gerador de petpack)
//   Cenario: Sign-in Clerk partilhado com a app
//     Dado um visitante sem sessao -> botao "Entrar com a conta PetCare"
//     E um utilizador com sessao na app -> formulario visivel + racas carregadas
//     (a sessao Clerk e' por dominio: icaro0310.github.io partilha /app e o site)

describe('Desktop Pet', () => {
  it('sign-in Clerk partilhado com a app', () => {
    // --- sem sessao: convite a entrar, formulario escondido ---------
    cy.visit('./desktop-pet.html');
    cy.get('#pd-signin', { timeout: 30_000 }).should('be.visible');
    cy.get('#pd-form').should('not.be.visible');
    cy.get('#pd-auth-msg').should('contain', 'Inicia sessão');

    // --- com sessao na app (mesmo dominio): formulario pronto -------
    cy.openApp();
    cy.visit('./desktop-pet.html');
    cy.get('#pd-form', { timeout: 30_000 }).should('be.visible');
    cy.get('#pd-auth-msg').should('contain', 'Sessão ativa');
    cy.get('#pd-signin').should('not.be.visible');
    // Raças da biblioteca carregadas via REST + token da sessao
    cy.get('#pd-breed option', { timeout: 15_000 })
      .its('length')
      .should('be.gt', 1);
  });
});
