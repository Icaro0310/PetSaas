/// <reference types="cypress" />

// Funcionalidade: Cuidadores
//   Cenario: Remover um cuidador do animal
//     Dado que o animal tem um cuidador com convite pendente
//     Quando toco em "Remover cuidador"
//     Entao o cuidador fica marcado como removido
describe('Cuidadores', () => {
  const stamp = Date.now() % 100000;
  const petName = `CgRem E2E ${stamp}`;
  const cgEmail = `cg.rem.${stamp}@example.com`;

  before(() => {
    cy.openApp();
    cy.createPetViaApi(petName).then((petId) => {
      cy.createCaregiverViaApi(petId, cgEmail);
    });
  });

  after(() => {
    cy.cleanupTestPets('CgRem E2E');
  });

  it('remove o cuidador e o estado fica "removed"', () => {
    cy.openApp();
    cy.openPet(petName);
    cy.tapAndWait('Cuidadores', { heading: 'Cuidadores' });
    cy.semNode(cgEmail).should('exist');
    cy.tapButton('Remover cuidador');
    cy.wait(1500);
    // O tile fica com status "removed" — verifica via REST (a linha nao
    // some da lista).
    cy.sbRest(
      'GET',
      'caregivers',
      `caregiver_email=eq.${cgEmail}&status=eq.removed&select=id`,
    ).then((rows) => {
      expect(rows.length).to.eq(1);
    });
  });
});
