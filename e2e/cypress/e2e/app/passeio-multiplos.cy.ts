/// <reference types="cypress" />

// Funcionalidade: Passeios
//   Cenario: Varios passeios por dia e eliminacao de registos
//     Dado que um animal ja tem um passeio registado hoje
//     Quando registo mais um passeio e depois elimino um registo
//     Entao a lista aceita varios passeios e respeita a eliminacao
describe('Passeios', () => {
  const stamp = Date.now() % 100000;
  const petName = `Walks E2E ${stamp}`;
  let petId = '';

  before(() => {
    cy.openApp();
    cy.createPetViaApi(petName).then((id) => {
      petId = id;
      cy.createWalkViaApi(id, { pee: true, notes: 'setup E2E' });
    });
  });

  after(() => {
    cy.openApp();
    cy.cleanupTestPets('Walks E2E');
  });

  it('aceita varios passeios por dia e elimina registos', () => {
    cy.openApp();
    cy.openPet(petName);
    cy.tapAndWait('Passeios', { heading: 'Passeios' });
    cy.semNode('setup E2E').should('exist');
    // Segundo passeio do dia via UI.
    cy.tapButton('Registar passeio');
    cy.tapButton('Cocô');
    cy.fillField('Notas', `passeio2 ${stamp}`);
    cy.tapButton('Registar');
    cy.semNode(`passeio2 ${stamp}`).should('exist');
    cy.sbRest('GET', 'walks', `select=id&pet_id=eq.${petId}`)
      .should('have.length', 2);
    // Eliminar um registo — confirmacao no dialog.
    cy.tapButton('Eliminar passeio');
    cy.tapButton('Eliminar');
    cy.sbRest('GET', 'walks', `select=id&pet_id=eq.${petId}`)
      .should('have.length', 1);
  });
});
