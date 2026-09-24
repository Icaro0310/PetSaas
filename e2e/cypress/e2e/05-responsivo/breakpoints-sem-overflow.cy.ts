/// <reference types="cypress" />

// Funcionalidade: Site em qualquer ecra
//   Cenario: Nenhum tamanho de ecra tem scroll horizontal
//     Dado que um visitante abre a pagina inicial
//     Quando o ecra tem 360, 768, 1280 ou 1440 pixeis de largura
//     Entao o conteudo cabe sempre na largura visivel
describe('Site em qualquer ecrã', () => {
  it('não há scroll horizontal em nenhum tamanho de ecrã', () => {
    for (const w of [360, 768, 1280, 1440]) {
      cy.viewport(w, 900);
      cy.visit('./');
      cy.document().should((doc) => {
        expect(doc.documentElement.scrollWidth).to.be.at.most(
          doc.documentElement.clientWidth + 1,
        );
      });
    }
  });
});
