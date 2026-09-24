/// <reference types="cypress" />

// Funcionalidade: Medicacao e doses
//   Cenario: O formulario de medicacao funciona para cada animal
//     Dado que existem dois animais na minha conta
//     Quando adiciono um medicamento a cada um
//     Entao cada animal fica com o seu medicamento na lista
describe('Medicação e doses', () => {
  const stamp = Date.now() % 100000;
  const pets = [`MedA E2E ${stamp}`, `MedB E2E ${stamp}`];

  before(() => {
    cy.openApp();
    pets.forEach((p) => cy.createPetViaApi(p));
  });

  after(() => {
    cy.openApp();
    cy.cleanupTestPets('MedA E2E');
    cy.cleanupTestPets('MedB E2E');
  });

  it('regista um medicamento por animal', () => {
    cy.openApp();
    pets.forEach((petName, i) => {
      const medName = `Remedio${i} E2E ${stamp}`;
      cy.openPet(petName);
      cy.tapAndWait('Medicamentos', { heading: 'Medicamentos' });
      cy.tapAndWait('Novo remedio', { text: 'Guardar remedio' });
      cy.fillField('Nome do remedio', medName);
      cy.fillField('Dosagem', '1 comprimido');
      cy.tapButton('Guardar remedio');
      cy.semNode(medName).should('exist');
      cy.go('back');
      cy.semNode('Meus pets').should('exist');
      cy.go('back');
      cy.semNode('Meus pets').should('exist');
    });
  });
});
