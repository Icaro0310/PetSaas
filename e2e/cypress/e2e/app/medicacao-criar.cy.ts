/// <reference types="cypress" />

// Funcionalidade: Medicacao e doses
//   Cenario: Registar um medicamento diario
//     Dado que existe um animal registado na minha conta
//     Quando adiciono um medicamento com nome e dosagem
//     Entao o medicamento aparece na lista do animal
describe('Medicação e doses', () => {
  const stamp = Date.now() % 100000;
  const petName = `MedPet E2E ${stamp}`;
  const medName = `Antibiotico E2E ${stamp}`;

  before(() => {
    cy.openApp();
    cy.createPetViaApi(petName);
  });

  after(() => {
    cy.cleanupTestPets('MedPet E2E');
  });

  it('regista um medicamento diário no animal', () => {
    cy.openApp();
    cy.openPet(petName);
    cy.tapAndWait('Medicamentos', { heading: 'Medicamentos' });
    cy.tapAndWait('Novo remedio', { text: 'Guardar remedio' });
    cy.fillField('Nome do remedio', medName);
    cy.fillField('Dosagem', '1 comprimido');
    // Frequencia default: Diario com horario 08:00.
    cy.tapButton('Guardar remedio');
    cy.semNode(medName).should('exist');
  });
});
