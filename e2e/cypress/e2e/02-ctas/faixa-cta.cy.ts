/// <reference types="cypress" />

// Funcionalidade: Convites para criar conta
//   Cenario: A faixa intermedia convida a comecar
//     Dado que um visitante percorre a pagina inicial
//     Quando chega a faixa "Pronto para comecar?"
//     Entao encontra o botao "Criar conta gratis" clicavel
describe('Convites para criar conta', () => {
  it('a faixa intermédia "Pronto para começar?" tem CTA clicável', () => {
    cy.visit('./');
    // Ha' 2 .cta-strip na pagina (a faixa do PetDesk tambem usa a classe)
    // — isola pela frase da faixa pretendida.
    cy.contains('.cta-strip', 'Pronto para começar?').scrollIntoView();
    cy.contains('.cta-strip', 'Pronto para começar?')
      .contains('a', 'Criar conta grátis')
      .should('be.visible');
  });
});
