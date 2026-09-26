import { app } from 'electron';
import * as path from 'path';
import * as fs from 'fs';
import { PetManifest } from './pet-window';

const ID_RE = /^[a-z0-9][a-z0-9_-]{0,63}$/;

export interface PetEntry {
  dir: string;
  manifest: PetManifest;
}

function isValidManifest(m: unknown): m is PetManifest {
  const o = m as PetManifest;
  return (
    !!o &&
    typeof o.id === 'string' &&
    ID_RE.test(o.id) &&
    typeof o.spritesheetPath === 'string' &&
    Array.isArray(o.frameSize) &&
    o.frameSize.length === 2 &&
    typeof o.states === 'object' &&
    !!o.states &&
    !!o.states.idle
  );
}

/** Devolve todos os pets: builtin + instalados em userData/pets/<id>/ */
export function listPets(builtinDir: string): PetEntry[] {
  const out: PetEntry[] = [];

  const tryDir = (dir: string) => {
    try {
      const m: unknown = JSON.parse(
        fs.readFileSync(path.join(dir, 'pet.json'), 'utf8')
      );
      if (!isValidManifest(m)) return;
      if (!fs.existsSync(path.join(dir, m.spritesheetPath))) return;
      if (out.some((p) => p.manifest.id === m.id)) return;
      out.push({ dir, manifest: m });
    } catch {
      /* pet invalido e' ignorado */
    }
  };

  tryDir(builtinDir);

  const petsRoot = path.join(app.getPath('userData'), 'pets');
  if (fs.existsSync(petsRoot)) {
    for (const name of fs.readdirSync(petsRoot)) {
      const dir = path.join(petsRoot, name);
      if (fs.statSync(dir).isDirectory()) tryDir(dir);
    }
  }
  return out;
}
