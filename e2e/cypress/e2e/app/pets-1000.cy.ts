/// <reference types="cypress" />

// Funcionalidade: Gestao de animais (teste de escala / edge)
//   Cenario: A conta e a lista aguentam um volume alto de animais
//     Dado que estou autenticado na aplicacao
//     Quando registo 1000 animais (caes e gatos aleatorios) via API
//     Entao a lista abre sem erros e todos podem ser eliminados
describe('Gestão de animais — escala', () => {
  const prefix = 'Mil E2E';
  const total = 1000;
  const batch = 250;

  after(() => {
    cy.openApp();
    cy.cleanupTestPets(prefix);
    cy.countPets(prefix).should('eq', 0);
  });

  it('insere 1000 animais, abre a lista e elimina tudo', () => {
    cy.openApp();
    cy.clerkUserId().then((ownerId) => {
      // POST em lotes — PostgREST aceita array num unico pedido.
      for (let b = 0; b < total / batch; b++) {
        const rows = Array.from({ length: batch }, (_, i) => ({
          owner_id: ownerId,
          name: `${prefix} ${String(b * batch + i).padStart(4, '0')}`,
          species: Math.random() < 0.5 ? 'dog' : 'cat',
        }));
        cy.sbRest('POST', 'pets', '', rows);
      }
    });
    cy.countPets(prefix).should('eq', total);
    cy.reload();
    cy.enableSemantics();
    cy.semNode('Meus pets').should('exist');
    cy.semNode(`${prefix} 0000`).should('exist');
    // Limpeza em massa dentro do proprio teste — a conta nao fica carregada.
    cy.cleanupTestPets(prefix);
    cy.countPets(prefix).should('eq', 0);
  });
});
