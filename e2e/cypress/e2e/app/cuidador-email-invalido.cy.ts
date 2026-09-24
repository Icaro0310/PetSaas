/// <reference types="cypress" />

// Funcionalidade: Cuidadores
//   Cenario: Um email invalido e rejeitado no convite
//     Dado que existe um animal registado na minha conta
//     Quando tento convidar um cuidador com email mal formatado
//     Entao vejo a mensagem "Email invalido"
describe('Cuidadores', () => {
  const petName = `CgVal E2E ${Date.now() % 100000}`;

  before(() => {
    cy.openApp();
    cy.createPetViaApi(petName);
  });

  after(() => {
    cy.cleanupTestPets('CgVal E2E');
  });

  it('rejeita o convite de cuidador com email inválido', () => {
    cy.openApp();
    cy.openPet(petName);
    cy.tapAndWait('Cuidadores', { heading: 'Cuidadores' });
    // Lista vazia -> EmptyState com acao "Convidar cuidador".
    cy.tapAndWait('Convidar cuidador', { text: 'Enviar convite' });
    cy.fillField('Email do cuidador', 'nao-e-email');
    cy.tapButton('Enviar convite');
    cy.semNode('Email invalido').should('exist');
  });
});
