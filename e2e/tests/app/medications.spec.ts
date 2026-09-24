import { test, expect } from '@playwright/test';
import {
  openApp,
  tapButton,
  fillField,
  nodeWithLabel,
  openPet,
  newSessionPage,
  createPetViaApi,
  cleanupTestPets,
  sbRest,
} from '../../helpers/app';

test.describe.serial('Medicacoes e doses', () => {
  const stamp = Date.now() % 100000;
  const petName = `MedPet E2E ${stamp}`;
  const medName = `Antibiotico E2E ${stamp}`;
  let petId: string;

  test.beforeAll(async ({ browser }) => {
    const { context, page } = await newSessionPage(browser);
    await openApp(page);
    petId = await createPetViaApi(page, petName);
    await context.close();
  });

  test.afterAll(async ({ browser }) => {
    const { context, page } = await newSessionPage(browser);
    await openApp(page);
    await cleanupTestPets(page, 'MedPet E2E');
    await context.close();
  });

  test('criar medicacao diaria', async ({ page }) => {
    await openApp(page);
    // petsProvider e realtime — o pet criado via REST aparece na lista
    await openPet(page, petName);
    await tapButton(page, 'Medicamentos');
    await tapButton(page, 'Novo remedio');
    await fillField(page, 'Nome do remedio', medName);
    await fillField(page, 'Dosagem', '1 comprimido');
    // Frequencia default: Diario com horario 08:00
    await tapButton(page, 'Guardar remedio');
    await expect(nodeWithLabel(page, medName)).toBeVisible({ timeout: 15_000 });
  });

  test('dose de hoje aparece e e marcada como dada', async ({ page }) => {
    await openApp(page);
    // Deterministico: garante uma dose pending hoje via REST (a dose das
    // 08:00 gerada pela UI pode ja ter sido marcada 'missed' pelo cron).
    const meds = await sbRest(
      page,
      'GET',
      'medications',
      `pet_id=eq.${petId}&name=eq.${encodeURIComponent(medName)}&select=id`,
    );
    // Hoje, num horario futuro (senao o cron marca 'missed' antes do clique)
    const in30min = new Date(Date.now() + 30 * 60 * 1000);
    const endOfToday = new Date();
    endOfToday.setUTCHours(23, 59, 0, 0);
    const scheduled =
      in30min < endOfToday ? in30min.toISOString() : endOfToday.toISOString();
    await sbRest(page, 'POST', 'dose_logs', '', {
      medication_id: meds[0].id,
      pet_id: petId,
      scheduled_time: scheduled,
      status: 'pending',
    });
    // Perfil -> Doses de hoje (mostra doses de hoje e proximas)
    await tapButton(page, 'Perfil e conta');
    await tapButton(page, 'Doses de hoje');
    await expect(nodeWithLabel(page, medName)).toBeVisible({ timeout: 15_000 });
    // "Dar remedio" e irmao do nome no DOM de semantica — clica o primeiro.
    await page
      .getByRole('button', { name: 'Dar remedio' })
      .first()
      .click();
    await tapButton(page, 'Confirmar');
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
