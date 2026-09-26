import { app } from 'electron';
import * as path from 'path';
import * as fs from 'fs';

export interface Settings {
  scale: number;          // 0.5 .. 3.0 (multiplicador de 1x=48px)
  opacity: number;        // 0.5 .. 1.0
  alwaysOnTop: boolean;
  mousePassthrough: boolean; // click-through com forwarding
  lockDragging: boolean;
  pauseInteractions: boolean;
  launchAtLogin: boolean;
  lang: 'pt' | 'en';
  activePet: string;      // id do pet
  petsaasToken: string;   // Clerk session token (guardado so' localmente)
}

const DEFAULTS: Settings = {
  scale: 3.0,
  opacity: 1.0,
  alwaysOnTop: true,
  mousePassthrough: false,
  lockDragging: false,
  pauseInteractions: false,
  launchAtLogin: false,
  lang: 'pt',
  activePet: 'chihuahua-pixel',
  petsaasToken: '',
};

let cache: Settings | null = null;

function filePath(): string {
  return path.join(app.getPath('userData'), 'settings.json');
}

export function getSettings(): Settings {
  if (cache) return cache;
  try {
    const raw = JSON.parse(fs.readFileSync(filePath(), 'utf8'));
    cache = { ...DEFAULTS, ...raw };
  } catch {
    cache = { ...DEFAULTS };
  }
  return cache as Settings;
}

export function setSetting<K extends keyof Settings>(
  key: K,
  value: Settings[K]
): void {
  const s = getSettings();
  s[key] = value;
  cache = s;
  fs.mkdirSync(path.dirname(filePath()), { recursive: true });
  fs.writeFileSync(filePath(), JSON.stringify(s, null, 2), 'utf8');
}
