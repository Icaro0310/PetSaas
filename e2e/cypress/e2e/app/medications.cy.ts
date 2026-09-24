/// <reference types="cypress" />

describe('Medicacoes e doses', () => {
  const stamp = Date.now() % 100000;
  const petName = `MedPet E2E ${stamp}`;
  const medName = `Antibiotico E2E ${stamp}`;
  let petId: string;

  before(() => {
    cy.openApp();
    cy.createPetViaApi(petName).then((id) => {
      petId = id;
    });
  });

  after(() => {
    cy.openApp();
    cy.cleanupTestPets('MedPet E2E');
  });

  it('criar medicacao diaria', () => {
    cy.openApp();
    // petsProvider e realtime — o pet criado via REST aparece na lista
    cy.openPet(petName);
    cy.tapAndWait('Medicamentos', { heading: 'Medicamentos' });
    cy.tapAndWait('Novo remedio', { text: 'Guardar remedio' });
    cy.fillField('Nome do remedio', medName);
    cy.fillField('Dosagem', '1 comprimido');
    // Frequencia default: Diario com horario 08:00
    cy.tapButton('Guardar remedio');
    cy.semNode(medName).should('exist');
  });

  it('dose de hoje aparece e e marcada como dada', () => {
    cy.openApp();
    // Deterministico: garante uma dose pending hoje via REST (a dose das
    // 08:00 gerada pela UI pode ja ter sido marcada 'missed' pelo cron).
    cy.sbRest(
      'GET',
      'medications',
      `pet_id=eq.${petId}&name=eq.${encodeURIComponent(medName)}&select=id`,
    ).then((meds) => {
      // Hoje, num horario futuro (senao o cron marca 'missed' antes do clique)
      const in30min = new Date(Date.now() + 30 * 60 * 1000);
      const endOfToday = new Date();
      endOfToday.setUTCHours(23, 59, 0, 0);
      const scheduled =
        in30min < endOfToday ? in30min.toISOString() : endOfToday.toISOString();
      cy.sbRest('POST', 'dose_logs', '', {
        medication_id: meds[0].id,
        pet_id: petId,
        scheduled_time: scheduled,
        status: 'pending',
      });
    });
    // Perfil -> Doses de hoje (mostra doses de hoje e proximas)
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
