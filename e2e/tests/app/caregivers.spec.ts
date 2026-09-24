import { test, expect } from '@playwright/test';
import {
  openApp,
  tapButton,
  fillField,
  nodeWithLabel,
  openPet,
  tapAndWait,
  newSessionPage,
  createPetViaApi,
  cleanupTestPets,
  sbRest,
} from '../../helpers/app';

test.describe.serial('Cuidadores', () => {
  const stamp = Date.now() % 100000;
  const petName = `CgPet E2E ${stamp}`;
  const cgEmail = `cg.e2e.${stamp}@example.com`;
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
    await cleanupTestPets(page, 'CgPet E2E');
    await context.close();
  });

  test('validacao de email invalido', async ({ page }) => {
    await openApp(page);
    await openPet(page, petName);
    await tapAndWait(page, 'Cuidadores', { heading: 'Cuidadores' });
    // Lista vazia -> EmptyState com acao "Convidar cuidador"
    await tapAndWait(page, 'Convidar cuidador', { text: 'Enviar convite' });
    await fillField(page, 'Email do cuidador', 'nao-e-email');
    await tapButton(page, 'Enviar convite');
    await expect(nodeWithLabel(page, 'Email invalido')).toBeVisible();
  });

  test('convidar cuidador', async ({ page }) => {
    await openApp(page);
    await openPet(page, petName);
    await tapAndWait(page, 'Cuidadores', { heading: 'Cuidadores' });
    await tapAndWait(page, 'Convidar cuidador', { text: 'Enviar convite' });
    await fillField(page, 'Email do cuidador', cgEmail);
    await tapButton(page, 'Enviar convite');
    await expect(nodeWithLabel(page, 'Convite criado')).toBeVisible({
      timeout: 15_000,
    });
  });

  test('cuidador aparece na lista e e removido', async ({ page }) => {
    await openApp(page);
    await openPet(page, petName);
    await tapAndWait(page, 'Cuidadores', { heading: 'Cuidadores' });
    await expect(nodeWithLabel(page, cgEmail)).toBeVisible({ timeout: 15_000 });
    await tapButton(page, 'Remover cuidador');
    await page.waitForTimeout(1500);
    // O tile fica com status "removed" — verifica via REST (a linha nao some da lista)
    const rows = await sbRest(
      page,
      'GET',
      'caregivers',
      `caregiver_email=eq.${cgEmail}&status=eq.removed&select=id`,
    );
    expect(rows.length).toBe(1);
  });
});
