import { test, expect } from '@playwright/test';
import {
  openApp,
  tapButton,
  tapAndWait,
  nodeWithLabel,
  TEST_EMAIL,
} from '../../helpers/app';

// DESTRUTIVO: elimina a conta de teste. So corre com E2E_ALLOW_DELETE_ACCOUNT=1
// e APENAS em emails clerk_test — nunca numa conta real.
const isSacrificial = TEST_EMAIL.endsWith('+clerk_test@example.com');
test.skip(
  process.env.E2E_ALLOW_DELETE_ACCOUNT !== '1' || !isSacrificial,
  'Delete account requer E2E_ALLOW_DELETE_ACCOUNT=1 e email +clerk_test',
);

test.describe.serial('Eliminar conta', () => {
  test('confirma e remove a conta', async ({ page }) => {
    await openApp(page);
    await tapAndWait(page, 'Perfil e conta', { heading: 'Perfil' });
    await tapButton(page, 'Eliminar conta');
    await tapButton(page, 'Eliminar definitivamente');
    // Conta eliminada -> sem sessao -> ecra de login
    await expect(nodeWithLabel(page, 'Iniciar sessão')).toBeVisible({
      timeout: 60_000,
    });
  });
});
