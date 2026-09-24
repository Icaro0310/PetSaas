/// <reference types="cypress" />

// Funcionalidade: Website publico PetCare
//   Cenario: Os documentos legais estao marcados como rascunho
//     Dado que um visitante abre os termos ou a privacidade
//     Entao a pagina esta marcada como "Documento em revisao"
//     E nao e indexada pelos motores de busca (noindex, nofollow)
//     E nao contem dados de exemplo por preencher
describe('Website publico', () => {
  it('documentos legais estão em revisão, não indexados e sem placeholders', () => {
    for (const path of ['terms.html', 'privacy.html']) {
      cy.visit(path);
      cy.get('meta[name="robots"]').should(
        'have.attr',
        'content',
        'noindex,nofollow',
      );
      cy.get('body')
        .invoke('text')
        .should('contain', 'Documento em revisão')
        .and(
          'not.match',
          /SEU_NOME|SEU_ENDERECO|app\.petcare\.com|legal@petcare\.com/i,
        );
    }
  });
});
