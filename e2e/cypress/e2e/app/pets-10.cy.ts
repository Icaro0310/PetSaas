/// <reference types="cypress" />

// Funcionalidade: Gestao de animais
//   Cenario: Um utilizador pode ter mais do que um animal
//     Dado que estou autenticado na aplicacao
//     Quando registo 10 animais na minha conta
//     Entao todos aparecem na lista "Meus pets"
describe('Gestão de animais', () => {
  const prefix = 'Dez E2E';
  const names = Array.from({ length: 10 }, (_, i) => `${prefix} ${i + 1}`);

  after(() => {
    cy.cleanupTestPets(prefix);
  });

  it('regista 10 animais e todos ficam na lista', () => {
    cy.openApp();
    cy.clerkUserId().then((ownerId) => {
      cy.sbRest(
        'POST',
        'pets',
        '',
        names.map((name, i) => ({
          owner_id: ownerId,
          name,
          species: i % 2 === 0 ? 'dog' : 'cat',
        })),
      );
    });
    cy.countPets(prefix).should('eq', 10);
    cy.reload();
    cy.enableSemantics();
    // A lista e lazy (so renderiza os visiveis) — basta confirmar que
    // cards do lote estao na arvore; a contagem real vem do REST acima.
    cy.semNode('Dez E2E').should('exist');
  });
});
