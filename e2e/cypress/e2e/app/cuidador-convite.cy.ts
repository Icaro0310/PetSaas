/// <reference types="cypress" />

// Funcionalidade: Cuidadores
//   Cenario: Enviar um convite de cuidador
//     Dado que existe um animal registado na minha conta
//     Quando convido um cuidador com um email valido
//     Entao vejo a confirmacao "Convite criado"
describe('Cuidadores', () => {
  const stamp = Date.now() % 100000;
  const petName = `CgInv E2E ${stamp}`;
  const cgEmail = `cg.e2e.${stamp}@example.com`;

  before(() => {
    cy.openApp();
    cy.createPetViaApi(petName);
  });

  after(() => {
    cy.cleanupTestPets('CgInv E2E');
  });

  it('envia o convite e mostra "Convite criado"', () => {
    cy.openApp();
    cy.openPet(petName);
    cy.tapAndWait('Cuidadores', { heading: 'Cuidadores' });
    cy.tapAndWait('Convidar cuidador', { text: 'Enviar convite' });
    cy.fillField('Email do cuidador', cgEmail);
    cy.tapButton('Enviar convite');
    cy.semNode('Convite criado').should('exist');
  });
});
