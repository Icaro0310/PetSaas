/// <reference types="cypress" />

// Funcionalidade: Site em qualquer ecra
//   Cenario: Nao ha barra de scroll horizontal no telemovel
//     Dado que um visitante abre a pagina inicial num telemovel
//     Entao o conteudo nao ultrapassa a largura do ecra
describe('Site em qualquer ecrã', () => {
  it('não há scroll horizontal no telemóvel', () => {
    cy.viewport(390, 844);
    cy.visit('./');
    cy.document().should((doc) => {
      expect(doc.documentElement.scrollWidth).to.be.at.most(
        doc.documentElement.clientWidth + 1,
      );
    });
  });
});
