/// <reference types="cypress" />

// Funcionalidade: Convites para criar conta
//   Cenario: A faixa intermedia convida a comecar
//     Dado que um visitante percorre a pagina inicial
//     Quando chega a faixa "Pronto para comecar?"
//     Entao encontra o botao "Criar conta gratis" clicavel
describe('Convites para criar conta', () => {
  it('a faixa intermédia "Pronto para começar?" tem CTA clicável', () => {
    cy.visit('./');
    cy.get('.cta-strip').scrollIntoView();
    cy.get('.cta-strip').should('contain.text', 'Pronto para começar?');
    cy.get('.cta-strip')
      .contains('a', 'Criar conta grátis')
      .should('be.visible');
  });
});
