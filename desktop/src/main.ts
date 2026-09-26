import { app, BrowserWindow, Menu, shell } from 'electron';
import * as path from 'path';
import * as url from 'url';

// A app web PetSaas (Flutter Web) vive neste dominio — carrega-la remote
// mantem a sessao Clerk partilhada com o site e o produto sempre atualizado.
const APP_ORIGIN = 'https://icaro0310.github.io';
const APP_URL = `${APP_ORIGIN}/PetSaas/app/`;

// Hosts do fluxo de auth (Clerk abre janelas/popups proprios).
const ALLOWED_HOSTS = [
  'icaro0310.github.io',
  'clerk.accounts.dev',
  'accounts.clerk.dev',
  'clerk.dev',
];

let win: BrowserWindow | null = null;

function isAppNavigation(target: string): boolean {
  try {
    const host = new url.URL(target).hostname;
    return ALLOWED_HOSTS.some(
      (h) => host === h || host.endsWith(`.${h}`)
    );
  } catch {
    return false;
  }
}

function createWindow(): void {
  win = new BrowserWindow({
    width: 1280,
    height: 820,
    minWidth: 1024,
    minHeight: 680,
    title: 'PetSaas',
    icon: path.join(__dirname, '..', 'icon.ico'),
    autoHideMenuBar: true,
    backgroundColor: '#F6F3EA',
    show: false,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true,
      // sessao persistente -> login Clerk sobrevive a restarts
      partition: 'persist:petsaas',
    },
  });

  win.once('ready-to-show', () => win?.show());

  // Navegacao fora da app (GitHub, docs, links externos) abre no browser.
  win.webContents.setWindowOpenHandler(({ url: target }) => {
    if (isAppNavigation(target)) return { action: 'allow' };
    shell.openExternal(target);
    return { action: 'deny' };
  });
  win.webContents.on('will-navigate', (e, target) => {
    if (!isAppNavigation(target)) {
      e.preventDefault();
      shell.openExternal(target);
    }
  });

  win.loadURL(APP_URL);
  win.on('closed', () => (win = null));
}

const gotLock = app.requestSingleInstanceLock();
if (!gotLock) {
  app.quit();
} else {
  app.on('second-instance', () => {
    if (win) {
      if (win.isMinimized()) win.restore();
      win.focus();
    }
  });

  Menu.setApplicationMenu(null);

  app.whenReady().then(() => {
    createWindow();
    app.on('activate', () => {
      if (BrowserWindow.getAllWindows().length === 0) createWindow();
    });
  });

  app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') app.quit();
  });
}
