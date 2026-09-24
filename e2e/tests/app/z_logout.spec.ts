import { test, expect } from '@playwright/test';
import {
  openApp,
  tapButton,
  nodeWithLabel,
} from '../../helpers/app';

// Corre por ultimo (z_): termina a sessao capturada.
test.describe.serial('Perfil e logout', () => {
  test('pagina de perfil mostra atalhos e acoes', async ({ page }) => {
    await openApp(page);
    await tapButton(page, 'Perfil e conta');
    await expect(nodeWithLabel(page, 'Perfil')).toBeVisible();
    await expect(nodeWithLabel(page, 'Doses de hoje')).toBeVisible({
      timeout: 15_000,
    });
    await expect(nodeWithLabel(page, 'Notificações')).toBeVisible();
    await expect(nodeWithLabel(page, 'Sair')).toBeVisible();
    await expect(nodeWithLabel(page, 'Eliminar conta')).toBeVisible();
  });

  test('logout volta ao ecra de login', async ({ page }) => {
    await openApp(page);
    await tapButton(page, 'Perfil e conta');
    await tapButton(page, 'Sair');
    // Clerk signOut redireciona para a base da app -> sem sessao -> login
    await expect(nodeWithLabel(page, 'Iniciar sessão')).toBeVisible({
      timeout: 30_000,
    });
    await expect(nodeWithLabel(page, 'Criar conta grátis')).toBeVisible();
  });
});
