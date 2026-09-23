import { test, expect } from '@playwright/test';
import {
  openApp,
  tapButton,
  nodeWithLabel,
  hasSession,
} from '../../helpers/app';

// DESTRUTIVO: elimina a conta de teste. So corre com E2E_ALLOW_DELETE_ACCOUNT=1
// e apenas contra a conta dedicada E2E (nunca a conta pessoal).
test.skip(
  !hasSession() || process.env.E2E_ALLOW_DELETE_ACCOUNT !== '1',
  'Delete account requer E2E_ALLOW_DELETE_ACCOUNT=1 e conta de teste dedicada',
);

test.describe.serial('Eliminar conta', () => {
  test('confirma e remove a conta', async ({ page }) => {
    await openApp(page, '/profile');
    await tapButton(page, 'Eliminar conta');
    await tapButton(page, 'Eliminar definitivamente');
    // Conta eliminada -> sem sessao -> ecra de login
    await expect(nodeWithLabel(page, 'Iniciar sessão')).toBeVisible({
      timeout: 60_000,
    });
  });
});
