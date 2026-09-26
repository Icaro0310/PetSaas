import { app, BrowserWindow, dialog, ipcMain, Menu, screen } from 'electron';
import * as path from 'path';
import {
  loadPet,
  resolveReaction,
  pickSpeech,
  PetContext,
} from './pet-window';
import { MotionEngine } from './motion-engine';
import { createTray } from './tray';
import { getSettings, setSetting, Settings } from './state';
import { listPets } from './pet-loader';
import { installPetpack, removePet } from './petpack';
import { startControlServer } from './control-server';
import { syncPetSaas } from './petsaas-sync';

const BUILTIN_DIR = path.join(__dirname, '..', '..', 'pets', 'builtin');
const IDLE_SLEEP_MS = 60_000;
const POMODORO_MS = 25 * 60_000;

let engine: MotionEngine | null = null;
let pet: PetContext | null = null;
let panel: BrowserWindow | null = null;
let mainMenu: Menu | null = null;

// estado funcional partilhado do pet atual
let lastActivity = Date.now();
let dozing = false;
let pomodoro: NodeJS.Timeout | null = null;

function say(reaction: string, ms = 2000): void {
  if (!pet) return;
  const line = pickSpeech(pet.manifest, reaction, getSettings().lang);
  if (line) pet.win.webContents.send('pet:say', line, ms);
}

function setState(reaction: string, ms?: number): void {
  if (!pet) return;
  pet.win.webContents.send(
    'pet:set-state',
    resolveReaction(pet.manifest, reaction),
    ms
  );
}

function sayText(text: string, ms = 3000): void {
  pet?.win.webContents.send('pet:say', text, ms);
}

function poke(): void {
  lastActivity = Date.now();
  if (dozing && !pomodoro) {
    dozing = false;
    engine?.setFocusMode(false);
    setState('idle');
  }
}

function wake(): void {
  dozing = false;
  engine?.setFocusMode(false);
}

function startPomodoro(): void {
  if (!engine) return;
  engine.setFocusMode(true);
  setState('sleeping');
  pet?.win.webContents.send('pet:say', 'Hora de focar! 25 min. Au.', 3000);
  pomodoro = setTimeout(() => {
    pomodoro = null;
    engine?.setFocusMode(false);
    setState('jumping', 3000);
    pet?.win.webContents.send(
      'pet:say',
      'Pomodoro completo! Bom trabalho!',
      4000
    );
  }, POMODORO_MS);
}

function cancelPomodoro(): void {
  if (pomodoro) clearTimeout(pomodoro);
  pomodoro = null;
  engine?.setFocusMode(false);
  setState('idle');
  pet?.win.webContents.send('pet:say', 'Pomodoro cancelado.', 2000);
}

function petDirOf(id: string): string {
  const entry = listPets(BUILTIN_DIR).find((p) => p.manifest.id === id);
  return entry ? entry.dir : BUILTIN_DIR;
}

function spawnPet(petId: string): void {
  if (pet && !pet.win.isDestroyed()) pet.win.destroy();
  engine?.stop();
  dozing = false;
  lastActivity = Date.now();

  pet = loadPet(petDirOf(petId));
  engine = new MotionEngine(pet.win, pet.size);
  const eng = engine;
  const p = pet;

  eng.onModeChange = (mode) => {
    if (mode !== 'idle') poke();
    const map: Record<string, string> = {
      idle: 'idle',
      walking: 'walking',
      dragging: 'held',
      falling: 'falling',
    };
    if ((pomodoro || dozing) && mode === 'idle') return;
    setState(map[mode]);
  };
  eng.onFacing = (dir) => p.win.webContents.send('pet:set-facing', dir);

  eng.start();
}

app.whenReady().then(() => {
  const settings = getSettings();
  app.setLoginItemSettings({ openAtLogin: settings.launchAtLogin });

  spawnPet(settings.activePet);
  createTray(() => pet, BUILTIN_DIR, openPanel);

  // ---- IPC do pet -----------------------------------------------------

  ipcMain.handle('pet:manifest', () => {
    if (!pet) return null;
    return {
      manifest: pet.manifest,
      spriteUrl: pet.spriteUrl,
      scale: pet.scale,
    };
  });

  ipcMain.on('pet:drag-start', () => {
    if (getSettings().lockDragging || !engine) return;
    poke();
    wake();
    engine.beginDrag();
  });
  ipcMain.on('pet:drag-move', () => engine?.moveDrag());
  ipcMain.on('pet:drag-end', () => engine?.endDrag());

  ipcMain.on('pet:click', () => {
    if (getSettings().pauseInteractions || pomodoro) return;
    poke();
    wake();
    setState('waving', 1600);
    say('waving', 2000);
  });

  ipcMain.on('pet:hover', () => {
    const s = getSettings();
    if (s.pauseInteractions || pomodoro || dozing) return;
    lastActivity = Date.now();
    setState('petted', 1200);
  });

  ipcMain.on('pet:dblclick', () => {
    if (getSettings().pauseInteractions) return;
    poke();
    if (pomodoro) cancelPomodoro();
    else {
      wake();
      startPomodoro();
    }
  });

  ipcMain.on('pet:contextmenu', (_e, pos: { x: number; y: number }) => {
    poke();
    rebuildMenu();
    mainMenu?.popup({ x: pos.x, y: pos.y });
  });

  // ---- control server local (MCP) --------------------------------------

  const controlServer = startControlServer({
    getState: () => ({
      mode: engine?.getMode(),
      pet: pet?.manifest.id,
      dozing,
      pomodoro: !!pomodoro,
      visible: pet?.win.isVisible() ?? false,
    }),
    setState: (state, ms) => {
      poke();
      setState(state, ms);
    },
    say: (text, ms) => sayText(text, ms),
    startPomodoro: () => {
      wake();
      startPomodoro();
    },
    cancelPomodoro,
    show: () => pet?.win.showInactive(),
    hide: () => pet?.win.hide(),
    listPets: () =>
      listPets(BUILTIN_DIR).map((p) => ({
        id: p.manifest.id,
        displayName: p.manifest.displayName,
      })),
    setPet: (id) => {
      if (!listPets(BUILTIN_DIR).some((p) => p.manifest.id === id)) {
        return false;
      }
      setSetting('activePet', id);
      spawnPet(id);
      return true;
    },
    installPetpack: async (zipPath) => {
      const res = await installPetpack(zipPath);
      if (res.ok && panel && !panel.isDestroyed()) {
        panel.webContents.send('panel:pets-changed');
      }
      return res;
    },
  });
  app.on('before-quit', () => controlServer.close());

  // soneca: 60s sem interacao -> dorme
  setInterval(() => {
    if (
      pet &&
      !pet.win.isDestroyed() &&
      !dozing &&
      !pomodoro &&
      engine?.getMode() === 'idle' &&
      Date.now() - lastActivity > IDLE_SLEEP_MS
    ) {
      dozing = true;
      engine.setFocusMode(true);
      setState('sleeping');
      say('sleeping', 3000);
    }
  }, 1000);

  // ---- IPC do painel --------------------------------------------------

  ipcMain.handle('panel:get-settings', () => getSettings());
  ipcMain.handle('panel:list-pets', () =>
    listPets(BUILTIN_DIR).map((p) => ({
      id: p.manifest.id,
      displayName: p.manifest.displayName,
    }))
  );
  ipcMain.on(
    'panel:set',
    <K extends keyof Settings>(_e: unknown, key: K, value: Settings[K]) => {
      setSetting(key, value);
      applySetting(key);
    }
  );
  ipcMain.on('panel:reset-position', () => resetPosition());
  ipcMain.on('panel:quit', () => app.quit());

  ipcMain.handle('panel:install-petpack', async () => {
    const r = await dialog.showOpenDialog({
      title: 'Instalar .petpack',
      filters: [{ name: 'PetPack', extensions: ['petpack', 'zip'] }],
      properties: ['openFile'],
    });
    if (r.canceled || r.filePaths.length === 0) return { ok: false };
    const res = await installPetpack(r.filePaths[0]);
    if (res.ok && panel && !panel.isDestroyed()) {
      panel.webContents.send('panel:pets-changed');
    }
    return res;
  });

  ipcMain.handle('panel:remove-pet', (_e, petId: string) => {
    if (petId === 'chihuahua-pixel') {
      return { ok: false, error: 'nao podes remover o pet builtin' };
    }
    const ok = removePet(petId);
    if (ok && getSettings().activePet === petId) {
      setSetting('activePet', 'chihuahua-pixel');
      spawnPet('chihuahua-pixel');
    }
    if (ok && panel && !panel.isDestroyed()) {
      panel.webContents.send('panel:pets-changed');
    }
    return { ok };
  });

  ipcMain.handle('panel:petsaas-sync', () => syncPetSaas());
});

// ---------- menu / panel -----------------------------------------------

function rebuildMenu(): void {
  mainMenu = Menu.buildFromTemplate([
    {
      label: pomodoro ? 'Cancelar Pomodoro' : 'Pomodoro (25 min)',
      click: () => {
        if (pomodoro) cancelPomodoro();
        else {
          wake();
          startPomodoro();
        }
      },
    },
    { label: 'Minimizar pet', click: () => pet?.win.hide() },
    { label: 'Resetar posicao', click: () => resetPosition() },
    { type: 'separator' },
    { label: 'Definicoes...', click: () => openPanel() },
    { type: 'separator' },
    { label: 'Sair', click: () => app.quit() },
  ]);
}

function resetPosition(): void {
  if (!pet) return;
  const { workArea } = screen.getPrimaryDisplay();
  pet.win.setPosition(
    workArea.x + workArea.width - pet.size - 40,
    workArea.y + workArea.height - pet.size
  );
}

function openPanel(): void {
  if (panel && !panel.isDestroyed()) {
    panel.focus();
    return;
  }
  panel = new BrowserWindow({
    width: 340,
    height: 430,
    title: 'PetDeskSaas',
    resizable: false,
    minimizable: false,
    maximizable: false,
    webPreferences: {
      preload: path.join(__dirname, '..', 'preload', 'panel-preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
    },
  });
  panel.setMenu(null);
  panel.loadFile(path.join(__dirname, '..', 'renderer', 'settings.html'));
  panel.on('closed', () => {
    panel = null;
  });
}

function applySetting(key: keyof Settings): void {
  if (!pet) return;
  const s = getSettings();
  switch (key) {
    case 'scale': {
      const size = pet.manifest.frameSize[1] * s.scale;
      pet.size = size;
      pet.scale = s.scale;
      pet.win.setSize(size, size);
      pet.win.webContents.send('pet:scale', s.scale);
      engine?.setSize(size);
      break;
    }
    case 'opacity':
      pet.win.setOpacity(s.opacity);
      break;
    case 'alwaysOnTop':
      pet.win.setAlwaysOnTop(s.alwaysOnTop, 'screen-saver');
      break;
    case 'mousePassthrough':
      pet.win.setIgnoreMouseEvents(s.mousePassthrough, { forward: true });
      break;
    case 'launchAtLogin':
      app.setLoginItemSettings({ openAtLogin: s.launchAtLogin });
      break;
    case 'activePet':
      spawnPet(s.activePet);
      break;
    // lockDragging / pauseInteractions / lang: lidas em tempo real
  }
}

app.on('window-all-closed', () => {
  // pet escondido nao fecha a app
});
