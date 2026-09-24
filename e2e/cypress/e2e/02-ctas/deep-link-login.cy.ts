/// <reference types="cypress" />

// Funcionalidade: Convites para criar conta
//   Cenario: Um link direto para o login funciona
//     Dado que um visitante abre o link direto /app/login
//     Entao a aplicacao restaura a rota e mostra o login
describe('Convites para criar conta', () => {
  it('o link direto /app/login resolve e mostra a página de login', () => {
    // Acesso direto a rota SPA: Pages serve 404.html que redireciona
    // para ?p= e a app restaura a URL limpa.
    cy.visit(`${Cypress.env('APP_URL')}/login`, { failOnStatusCode: false });
    cy.location('pathname', { timeout: 30_000 }).should(
      'match',
      /\/PetSaas\/app\/login/,
    );
  });
});
