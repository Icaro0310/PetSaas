/// <reference types="cypress" />

// Funcionalidade: Gestao de animais
//   Cenario: Editar o nome de um animal
//     Dado que existe um animal registado na minha conta
//     Quando altero o nome no formulario de edicao
//     Entao o novo nome aparece na lista "Meus pets"
describe('Gestão de animais', () => {
  const stamp = Date.now() % 100000;
  const petName = `EditPet E2E ${stamp}`;
  const petRenamed = `EditPet E2E ${stamp} Novo`;

  before(() => {
    cy.openApp();
    cy.createPetViaApi(petName);
  });

  after(() => {
    cy.openApp();
    cy.cleanupTestPets('EditPet E2E');
  });

  it('edita o nome do animal e o novo nome aparece na lista', () => {
    cy.openApp();
    cy.openPet(petName);
    cy.tapAndWait('Editar', { text: 'Guardar alteracoes' });
    cy.fillField('Nome *', petRenamed);
    cy.tapButton('Guardar alteracoes');
    cy.semNode(petRenamed).should('exist');
  });
});
