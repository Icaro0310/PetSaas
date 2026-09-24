/// <reference types="cypress" />

// Funcionalidade: Gestao de animais
//   Cenario: O formulario rejeita dados invalidos
//     Dado que estou autenticado na aplicacao
//     Quando tento criar um animal sem nome
//     Entao vejo "Nome obrigatorio"
//     E quando indico um peso acima do maximo
//     Entao vejo o aviso do limite 999,99
describe('Gestão de animais', () => {
  it('o formulário rejeita nome vazio e peso acima do máximo', () => {
    cy.openApp();
    cy.tapAndWait('Adicionar pet', { heading: 'Novo pet' });
    // Submeter vazio -> erro de nome obrigatorio.
    cy.tapButton('Criar pet');
    cy.semNode('Nome obrigatorio').should('exist');
    // Peso acima do maximo (numeric(5,2) -> 999,99).
    cy.fillField('Peso', '1500');
    cy.tapButton('Criar pet');
    cy.semNode('999,99').should('exist');
  });
});
