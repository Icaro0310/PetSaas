import { test, expect } from '@playwright/test';
import {
  openApp,
  tapButton,
  fillField,
  nodeWithLabel,
  openPet,
  tapAndWait,
  newSessionPage,
  cleanupTestPets,
  sbRest,
  PNG_1PX,
} from '../../helpers/app';

test.describe.serial('Pets', () => {
  const stamp = Date.now() % 100000;
  const petName = `Rex E2E ${stamp}`;
  const petRenamed = `Rex E2E ${stamp} Editado`;

  test.afterAll(async ({ browser }) => {
    const { context, page } = await newSessionPage(browser);
    await openApp(page);
    await cleanupTestPets(page, 'Rex E2E');
    await cleanupTestPets(page, 'Foto E2E');
    await context.close();
  });

  test('validacao do formulario (nome e peso)', async ({ page }) => {
    await openApp(page);
    await tapAndWait(page, 'Adicionar pet', { heading: 'Novo pet' });
    // Submeter vazio -> erro de nome obrigatorio
    await tapButton(page, 'Criar pet');
    await expect(nodeWithLabel(page, 'Nome obrigatorio')).toBeVisible({
      timeout: 10_000,
    });
    // Peso acima do maximo (numeric(5,2) -> 999,99)
    await fillField(page, 'Peso', '1500');
    await tapButton(page, 'Criar pet');
    await expect(nodeWithLabel(page, '999,99')).toBeVisible();
  });

  test('criar pet sem foto', async ({ page }) => {
    await openApp(page);
    await tapAndWait(page, 'Adicionar pet', { heading: 'Novo pet' });
    await fillField(page, 'Nome *', petName);
    await tapButton(page, 'Criar pet');
    // Volta a lista e o pet aparece
    await expect(nodeWithLabel(page, 'Meus pets')).toBeVisible({
      timeout: 15_000,
    });
    await expect(nodeWithLabel(page, petName)).toBeVisible();
  });

  test('criar pet com foto', async ({ page }) => {
    await openApp(page);
    await tapAndWait(page, 'Adicionar pet', { heading: 'Novo pet' });
    const name = `Foto E2E ${stamp}`;
    await fillField(page, 'Nome *', name);
    // PhotoPicker -> bottom sheet -> Galeria -> file chooser
    await tapButton(page, 'Selecionar foto');
    // Regista o wait ANTES do clique — o filechooser dispara no tap.
    const chooserPromise = page.waitForEvent('filechooser', {
      timeout: 15_000,
    });
    await tapButton(page, 'Galeria');
    const chooser = await chooserPromise;
    await chooser.setFiles({
      name: 'e2e.png',
      mimeType: 'image/png',
      buffer: PNG_1PX,
    });
    await tapButton(page, 'Criar pet');
    await expect(nodeWithLabel(page, name)).toBeVisible({ timeout: 20_000 });
    // photo_url tem de ter sido gravado
    const rows = await sbRest(
      page,
      'GET',
      'pets',
      `name=eq.${encodeURIComponent(name)}&select=photo_url`,
    );
    expect(rows[0].photo_url).toBeTruthy();
  });

  test('editar pet', async ({ page }) => {
    await openApp(page);
    await openPet(page, petName);
    await tapAndWait(page, 'Editar', { text: 'Guardar alteracoes' });
    await fillField(page, 'Nome *', petRenamed);
    await tapButton(page, 'Guardar alteracoes');
    await expect(nodeWithLabel(page, petRenamed)).toBeVisible({
      timeout: 15_000,
    });
  });
});
