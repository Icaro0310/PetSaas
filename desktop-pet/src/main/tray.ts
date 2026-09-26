import { app, Menu, Tray, nativeImage } from 'electron';
import * as path from 'path';
import { PetContext } from './pet-window';

export function createTray(
  getPet: () => PetContext | null,
  petDir: string,
  onShowPanel: () => void
): Tray {
  const iconPath = path.join(petDir, 'tray.png');
  const icon = nativeImage.createFromPath(iconPath);
  const tray = new Tray(icon.isEmpty() ? nativeImage.createEmpty() : icon);
  tray.setToolTip('PetDeskSaas');

  const toggle = () => {
    const pet = getPet();
    if (!pet || pet.win.isDestroyed()) return;
    pet.win.isVisible() ? pet.win.hide() : pet.win.showInactive();
    refresh();
  };

  const menu = () => {
    const pet = getPet();
    const visible = !!pet && !pet.win.isDestroyed() && pet.win.isVisible();
    return Menu.buildFromTemplate([
      {
        label: visible ? 'Esconder pet' : 'Mostrar pet',
        click: toggle,
      },
      {
        label: 'Definicoes...',
        click: onShowPanel,
      },
      { type: 'separator' },
      {
        label: 'Sair',
        click: () => app.quit(),
      },
    ]);
  };

  const refresh = () => tray.setContextMenu(menu());
  tray.on('click', toggle);
  refresh();
  return tray;
}
