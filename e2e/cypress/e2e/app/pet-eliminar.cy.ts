/// <reference types="cypress" />

// Funcionalidade: Gestao de animais
//   Cenario: Eliminar um animal registado
//     Dado que existe um animal na minha conta
//     Quando abro o detalhe e confirmo "Eliminar pet"
//     Entao o animal desaparece da lista e da base de dados
describe('Gestão de animais', () => {
  const petName = `Del E2E ${Date.now() % 100000}`;

  before(() => {
    cy.openApp();
    cy.createPetViaApi(petName);
  });

  after(() => {
    cy.cleanupTestPets('Del E2E');
  });

  it('elimina o animal pelo detalhe e confirma a remocao', () => {
    cy.openApp();
    cy.openPet(petName);
    cy.tapButton('Eliminar pet');
    // Dialog de confirmacao — o botao destrutivo diz "Eliminar pet".
    cy.semNode('Elimina o pet e todos os dados').should('exist');
    cy.tapButton('Eliminar pet');
    cy.semNode('Meus pets').should('exist');
    cy.countPets('Del E2E').should('eq', 0);
  });
});
