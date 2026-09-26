import { BrowserWindow, screen } from 'electron';
import * as path from 'path';
import * as fs from 'fs';
import { pathToFileURL } from 'url';
import { getSettings } from './state';

export interface PetState {
  row: number;
  frames: number;
  fps: number;
}

export interface PetManifest {
  id: string;
  displayName: string;
  frameSize: [number, number];
  spritesheetPath: string;
  states: Record<string, PetState>;
  reactionMap: Record<string, string>;
  speech: Record<string, Record<string, string[]>>;
}

export interface PetContext {
  win: BrowserWindow;
  manifest: PetManifest;
  spriteUrl: string;
  scale: number;
  size: number; // janela quadrada: frameH * scale
}

export function loadPet(petDir: string): PetContext {
  const settings = getSettings();
  const scale = settings.scale;
  const manifest: PetManifest = JSON.parse(
    fs.readFileSync(path.join(petDir, 'pet.json'), 'utf8')
  );
  const spriteUrl = pathToFileURL(
    path.join(petDir, manifest.spritesheetPath)
  ).href;

  const size = manifest.frameSize[1] * scale;
  const { workArea } = screen.getPrimaryDisplay();

  const win = new BrowserWindow({
    width: size,
    height: size,
    x: workArea.x + workArea.width - size - 40,
    y: workArea.y + workArea.height - size,
    transparent: true,
    frame: false,
    alwaysOnTop: settings.alwaysOnTop,
    skipTaskbar: true,
    resizable: false,
    hasShadow: false,
    focusable: false,
    webPreferences: {
      preload: path.join(__dirname, '..', 'preload', 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
    },
  });

  win.setAlwaysOnTop(settings.alwaysOnTop, 'screen-saver');
  win.setOpacity(settings.opacity);
  win.setMenu(null);
  win.loadFile(path.join(__dirname, '..', 'renderer', 'pet.html'));

  return { win, manifest, spriteUrl, scale, size };
}

export function resolveReaction(
  manifest: PetManifest,
  reaction: string
): string {
  const state = manifest.reactionMap[reaction] ?? reaction;
  return manifest.states[state] ? state : 'idle';
}

export function pickSpeech(
  manifest: PetManifest,
  reaction: string,
  lang = 'pt'
): string | null {
  const pool =
    manifest.speech?.[lang]?.[reaction] ??
    manifest.speech?.[lang]?.['waving'];
  if (!pool || pool.length === 0) return null;
  return pool[Math.floor(Math.random() * pool.length)];
}
