/// <reference types="cypress" />

describe('Cuidadores', () => {
  const stamp = Date.now() % 100000;
  const petName = `CgPet E2E ${stamp}`;
  const cgEmail = `cg.e2e.${stamp}@example.com`;
  let petId: string;

  before(() => {
    cy.openApp();
    cy.createPetViaApi(petName).then((id) => {
      petId = id;
    });
  });

  after(() => {
    cy.openApp();
    cy.cleanupTestPets('CgPet E2E');
  });

  it('validacao de email invalido', () => {
    cy.openApp();
    cy.openPet(petName);
    cy.tapAndWait('Cuidadores', { heading: 'Cuidadores' });
    // Lista vazia -> EmptyState com acao "Convidar cuidador"
    cy.tapAndWait('Convidar cuidador', { text: 'Enviar convite' });
    cy.fillField('Email do cuidador', 'nao-e-email');
    cy.tapButton('Enviar convite');
    cy.semNode('Email invalido').should('exist');
  });

  it('convidar cuidador', () => {
    cy.openApp();
    cy.openPet(petName);
    cy.tapAndWait('Cuidadores', { heading: 'Cuidadores' });
    cy.tapAndWait('Convidar cuidador', { text: 'Enviar convite' });
    cy.fillField('Email do cuidador', cgEmail);
    cy.tapButton('Enviar convite');
    cy.semNode('Convite criado').should('exist');
  });

  it('cuidador aparece na lista e e removido', () => {
    cy.openApp();
    cy.openPet(petName);
    cy.tapAndWait('Cuidadores', { heading: 'Cuidadores' });
    cy.semNode(cgEmail).should('exist');
    cy.tapButton('Remover cuidador');
    cy.wait(1500);
    // O tile fica com status "removed" — verifica via REST (a linha nao some da lista)
    cy.sbRest(
      'GET',
      'caregivers',
      `caregiver_email=eq.${cgEmail}&status=eq.removed&select=id`,
    ).then((rows) => {
      expect(rows.length).to.eq(1);
    });
  });
});
