/// <reference types="cypress" />

// PNG 1x1 para upload de foto em testes.
const PNG_1PX_B64 =
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

// Funcionalidade: Gestao de animais
//   Cenario: Criar um animal com fotografia
//     Dado que estou autenticado na aplicacao
//     Quando crio um animal e escolho uma foto da galeria
//     Entao o animal aparece na lista
//     E a foto fica gravada no armazenamento (photo_url)
describe('Gestão de animais', () => {
  const petName = `Foto E2E ${Date.now() % 100000}`;

  after(() => {
    cy.cleanupTestPets('Foto E2E');
  });

  it('cria um animal com foto e grava a imagem no armazenamento', () => {
    cy.openApp();
    cy.tapAndWait('Adicionar pet', { heading: 'Novo pet' });
    cy.fillField('Nome *', petName);
    // PhotoPicker -> bottom sheet -> Galeria -> <input type="file">
    // (o Cypress intercepta o file chooser — nao abre dialogo nativo).
    cy.tapButton('Selecionar foto');
    cy.tapButton('Galeria');
    // O plugin cria o input por pick — o .last() e o do pick atual.
    cy.get('input[type="file"]', { timeout: 15_000 })
      .last()
      .selectFile(
        {
          contents: Cypress.Buffer.from(PNG_1PX_B64, 'base64'),
          fileName: 'e2e.png',
          mimeType: 'image/png',
        },
        { force: true },
      );
    // Gate: 'Remover foto' so existe quando o preview recebeu a imagem —
    // prova de que o pick resolveu antes de submeter.
    cy.semNode('Remover foto').should('exist');
    cy.tapButton('Criar pet');
    cy.semNode(petName).should('exist');
    // photo_url tem de ter sido gravado.
    cy.sbRest(
      'GET',
      'pets',
      `name=eq.${encodeURIComponent(petName)}&select=photo_url`,
    ).then((rows) => {
      expect(rows[0].photo_url).to.be.ok;
    });
  });
});
