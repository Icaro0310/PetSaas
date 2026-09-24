/// <reference types="cypress" />

// Funcionalidade: Medicacao e doses
//   Cenario: Marcar a dose de hoje como administrada
//     Dado que existe uma dose pendente para hoje
//     Quando abro "Doses de hoje" e toco em "Dar remedio"
//     Entao a dose fica registada como administrada
describe('Medicação e doses', () => {
  const stamp = Date.now() % 100000;
  const petName = `DosePet E2E ${stamp}`;
  const medName = `Vitamina E2E ${stamp}`;
  let petId: string;

  before(() => {
    cy.openApp();
    cy.createPetViaApi(petName).then((id) => {
      petId = id;
      cy.createMedicationViaApi(id, medName).then((medId) => {
        // Dose pending num horario futuro de hoje — senao o cron marca
        // 'missed' antes do clique.
        cy.createPendingDoseViaApi(id, medId);
      });
    });
  });

  after(() => {
    cy.cleanupTestPets('DosePet E2E');
  });

  it('marca a dose pendente como administrada', () => {
    cy.openApp();
    // Perfil -> Doses de hoje (mostra doses de hoje e proximas).
    cy.tapAndWait('Perfil e conta', { heading: 'Perfil' });
    cy.tapAndWait('Doses de hoje', { heading: 'Doses de hoje' });
    cy.semNode(medName).should('exist');
    // "Dar remedio" e irmao do nome no DOM de semantica — clica o primeiro.
    cy.get('flt-semantics[role="button"]')
      .contains('Dar remedio')
      .first()
      .click({ force: true });
    cy.tapButton('Confirmar');
    cy.wait(2000);
    cy.sbRest(
      'GET',
      'dose_logs',
      `pet_id=eq.${petId}&status=eq.given&select=id`,
    ).then((rows) => {
      expect(rows.length).to.be.greaterThan(0);
    });
  });
});
