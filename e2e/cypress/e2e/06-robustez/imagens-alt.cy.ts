/// <reference types="cypress" />

// Funcionalidade: Site resistente a falhas
//   Cenario: Todas as imagens tem texto alternativo
//     Dado que um visitante abre a pagina inicial
//     Entao cada imagem tem uma descricao para leitores de ecra
describe('Site resistente a falhas', () => {
  it('todas as imagens têm texto alternativo (alt)', () => {
    cy.visit('./');
    cy.get('img').each(($img) => {
      expect($img.attr('alt'), `alt de ${$img.attr('src')}`).to.be.a('string');
    });
  });
});
