import { test, expect } from '@playwright/test';
import {
  openApp,
  tapButton,
  fillField,
  nodeWithLabel,
  hasSession,
  createPetViaApi,
  cleanupTestPets,
} from '../../helpers/app';

test.skip(!hasSession(), 'Sem sessao E2E — corre `npm run auth` primeiro');

test.describe.serial('Cuidadores', () => {
  const stamp = Date.now() % 100000;
  const petName = `CgPet E2E ${stamp}`;
  const cgEmail = `cg.e2e.${stamp}@example.com`;
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

  test('validacao de email invalido', async ({ page }) => {
    await openApp(page, `/invite/${petId}`);
    await fillField(page, 'Email do cuidador', 'nao-e-email');
    await tapButton(page, 'Enviar convite');
    await expect(nodeWithLabel(page, 'Email invalido')).toBeVisible();
  });

  test('convidar cuidador', async ({ page }) => {
    await openApp(page, `/invite/${petId}`);
    await fillField(page, 'Email do cuidador', cgEmail);
    await tapButton(page, 'Enviar convite');
    await expect(nodeWithLabel(page, 'Convite criado')).toBeVisible({
      timeout: 15_000,
    });
  });

  test('cuidador aparece na lista e e removido', async ({ page }) => {
    await openApp(page, `/caregivers/${petId}`);
    await expect(nodeWithLabel(page, cgEmail)).toBeVisible({ timeout: 15_000 });
    await tapButton(page, 'Remover cuidador');
    await page.waitForTimeout(1500);
    await expect(nodeWithLabel(page, cgEmail)).toHaveCount(0);
  });
});
