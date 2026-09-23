import { test, expect } from '@playwright/test';
import {
  openApp,
  tapButton,
  fillField,
  nodeWithLabel,
  hasSession,
  createPetViaApi,
  cleanupTestPets,
  sbRest,
} from '../../helpers/app';

test.skip(!hasSession(), 'Sem sessao E2E — corre `npm run auth` primeiro');

test.describe.serial('Medicacoes e doses', () => {
  const stamp = Date.now() % 100000;
  const petName = `MedPet E2E ${stamp}`;
  const medName = `Antibiotico E2E ${stamp}`;
  let petId: string;

  test.beforeAll(async ({ browser }) => {
    const page = await browser.newPage();
    await openApp(page);
    petId = await createPetViaApi(page, petName);
    await page.close();
  });

  test.afterAll(async ({ browser }) => {
    const page = await browser.newPage();
    await openApp(page);
    await cleanupTestPets(page);
    await page.close();
  });

  test('criar medicacao diaria', async ({ page }) => {
    await openApp(page, `/pet/${petId}`);
    await tapButton(page, 'Medicamentos');
    await tapButton(page, 'Novo remedio');
    await fillField(page, 'Nome do remedio', medName);
    await fillField(page, 'Dosagem', '1 comprimido');
    // Frequencia default: Diario (RadioGroup)
    await tapButton(page, 'Guardar remedio');
    await expect(nodeWithLabel(page, medName)).toBeVisible({ timeout: 15_000 });
  });

  test('dose de hoje aparece e e marcada como dada', async ({ page }) => {
    await openApp(page, '/today');
    await expect(nodeWithLabel(page, medName)).toBeVisible({ timeout: 15_000 });
    // Botao "Dar remedio" dentro do card desta medicacao (a conta pode ter outras doses)
    await page
      .locator('flt-semantics', { hasText: medName })
      .locator('flt-semantics[role="button"]:has-text("Dar remedio")')
      .first()
      .click();
    await tapButton(page, 'Confirmar');
    // Estado 'given' persistido
    await page.waitForTimeout(2000);
    const rows = await sbRest(
      page,
      'GET',
      'dose_logs',
      `pet_id=eq.${petId}&status=eq.given&select=id`,
    );
    expect(rows.length).toBeGreaterThan(0);
  });
});
