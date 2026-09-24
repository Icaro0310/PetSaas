/// <reference types="cypress" />

// Funcionalidade: Convites para criar conta
//   Cenario: A pagina de precos diz que tudo e gratuito
//     Dado que um visitante abre a pagina de precos
//     Entao o titulo diz "PetCare e gratuito"
//     E o cartao lista as funcionalidades incluidas
//     E o botao convida a criar conta
describe('Convites para criar conta', () => {
  it('a página de preços diz "PetCare é gratuito" e convida a registar', () => {
    cy.visit('pricing.html');
    cy.get('h1').should('contain.text', 'PetCare é gratuito');
    cy.get('.price-card').within(() => {
      cy.contains('Perfis para vários animais');
      cy.contains('a', 'Criar conta grátis').should('be.visible');
    });
  });
});
