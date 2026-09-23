import { test, expect } from '@playwright/test';
import {
  openApp,
  tapButton,
  nodeWithLabel,
  hasSession,
} from '../../helpers/app';

test.skip(!hasSession(), 'Sem sessao E2E — corre `npm run auth` primeiro');

// Corre por ultimo (z_): termina a sessao capturada.
test.describe.serial('Perfil e logout', () => {
  test('pagina de perfil mostra email e atalhos', async ({ page }) => {
    await openApp(page, '/profile');
    await expect(nodeWithLabel(page, 'Perfil')).toBeVisible();
    await expect(nodeWithLabel(page, 'Doses de hoje')).toBeVisible({
      timeout: 15_000,
    });
    await expect(nodeWithLabel(page, 'Notificações')).toBeVisible();
    await expect(nodeWithLabel(page, 'Sair')).toBeVisible();
    await expect(nodeWithLabel(page, 'Eliminar conta')).toBeVisible();
  });

  test('logout volta ao ecra de login', async ({ page }) => {
    await openApp(page, '/profile');
    await tapButton(page, 'Sair');
    // Clerk signOut redireciona para a base da app -> sem sessao -> login
    await expect(nodeWithLabel(page, 'Iniciar sessão')).toBeVisible({
      timeout: 30_000,
    });
    await expect(nodeWithLabel(page, 'Criar conta grátis')).toBeVisible();
  });
});
