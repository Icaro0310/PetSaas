/// <reference types="cypress" />

// Funcionalidade: Gestao de animais
//   Cenario: Criar um animal sem fotografia
//     Dado que estou autenticado na aplicacao
//     Quando crio um animal apenas com o nome
//     Entao o animal aparece na lista "Meus pets"
describe('Gestão de animais', () => {
  const petName = `Rex E2E ${Date.now() % 100000}`;

  after(() => {
    cy.cleanupTestPets('Rex E2E');
  });

  it('cria um animal sem fotografia e mostra-o na lista', () => {
    cy.openApp();
    cy.tapAndWait('Adicionar pet', { heading: 'Novo pet' });
    cy.fillField('Nome *', petName);
    cy.tapButton('Criar pet');
    cy.semNode('Meus pets').should('exist');
    cy.semNode(petName).should('exist');
  });
});
