/// <reference types="cypress" />

// PNG 1x1 para upload de foto em testes.
const PNG_1PX_B64 =
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

describe('Pets', () => {
  const stamp = Date.now() % 100000;
  const petName = `Rex E2E ${stamp}`;
  const petRenamed = `Rex E2E ${stamp} Editado`;

  after(() => {
    cy.openApp();
    cy.cleanupTestPets('Rex E2E');
    cy.cleanupTestPets('Foto E2E');
  });

  it('validacao do formulario (nome e peso)', () => {
    cy.openApp();
    cy.tapAndWait('Adicionar pet', { heading: 'Novo pet' });
    // Submeter vazio -> erro de nome obrigatorio
    cy.tapButton('Criar pet');
    cy.semNode('Nome obrigatorio').should('exist');
    // Peso acima do maximo (numeric(5,2) -> 999,99)
    cy.fillField('Peso', '1500');
    cy.tapButton('Criar pet');
    cy.semNode('999,99').should('exist');
  });

  it('criar pet sem foto', () => {
    cy.openApp();
    cy.tapAndWait('Adicionar pet', { heading: 'Novo pet' });
    cy.fillField('Nome *', petName);
    cy.tapButton('Criar pet');
    // Volta a lista e o pet aparece
    cy.semNode('Meus pets').should('exist');
    cy.semNode(petName).should('exist');
  });

  it('criar pet com foto', () => {
    cy.openApp();
    cy.tapAndWait('Adicionar pet', { heading: 'Novo pet' });
    const name = `Foto E2E ${stamp}`;
    cy.fillField('Nome *', name);
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
    cy.semNode(name).should('exist');
    // photo_url tem de ter sido gravado
    cy.sbRest(
      'GET',
      'pets',
      `name=eq.${encodeURIComponent(name)}&select=photo_url`,
    ).then((rows) => {
      expect(rows[0].photo_url).to.be.ok;
    });
  });

  it('editar pet', () => {
    cy.openApp();
    cy.openPet(petName);
    cy.tapAndWait('Editar', { text: 'Guardar alteracoes' });
    cy.fillField('Nome *', petRenamed);
    cy.tapButton('Guardar alteracoes');
    cy.semNode(petRenamed).should('exist');
  });
});
