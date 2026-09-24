/// <reference types="cypress" />

// Funcionalidade: Passeios
//   Cenario: Registar um passeio com Coco e Xixi
//     Dado que existe um animal registado na minha conta
//     Quando abro "Passeios" e registo um passeio marcando Coco e Xixi
//     Entao o passeio aparece na lista com as etiquetas certas
describe('Passeios', () => {
  const petName = `Walk E2E ${Date.now() % 100000}`;

  before(() => {
    cy.openApp();
    cy.createPetViaApi(petName);
  });

  after(() => {
    cy.openApp();
    cy.cleanupTestPets('Walk E2E');
  });

  it('regista um passeio com Coco e Xixi marcados', () => {
    cy.openApp();
    cy.openPet(petName);
    cy.tapAndWait('Passeios', { heading: 'Passeios' });
    // Lista vazia -> EmptyState com acao "Registar passeio".
    cy.tapButton('Registar passeio');
    cy.semNode('Registar passeio').should('exist');
    cy.tapButton('Cocô');
    cy.tapButton('Xixi');
    cy.tapButton('Registar');
    cy.semNode('Cocô').should('exist');
    cy.semNode('Xixi').should('exist');
    cy.sbRest('GET', 'walks', 'select=poop,pee&poop=eq.true&pee=eq.true')
      .should('have.length.at.least', 1);
  });
});
