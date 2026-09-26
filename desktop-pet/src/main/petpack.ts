import { app } from 'electron';
import * as path from 'path';
import * as fs from 'fs';
import * as yauzl from 'yauzl';

const ID_RE = /^[a-z0-9][a-z0-9_-]{0,63}$/;
const ALLOWED_EXT = new Set(['.json', '.webp', '.png', '.gif']);
const MAX_ENTRIES = 200;
const MAX_FILE_BYTES = 50 * 1024 * 1024;
const MAX_TOTAL_BYTES = 200 * 1024 * 1024;

/** entry name seguro: relativo, sem traversal, sem drive/unc, sem backslash tricks */
function safeEntryName(name: string): boolean {
  if (!name || name.length > 255) return false;
  if (name.includes('\0') || name.includes('\\')) return false;
  if (path.isAbsolute(name) || /^[a-zA-Z]:/.test(name) || name.startsWith('/')) {
    return false;
  }
  const parts = name.split('/');
  if (parts.some((p) => p === '..' || p === '.' || p === '')) return false;
  return true;
}

export interface InstallResult {
  ok: boolean;
  petId?: string;
  error?: string;
}

/**
 * Instala um .petpack (ZIP com pet.json + spritesheet) em
 * userData/pets/<id>/. Valida manifest antes de escrever.
 */
export async function installPetpack(zipPath: string): Promise<InstallResult> {
  const petsRoot = path.join(app.getPath('userData'), 'pets');

  // 1. lista e valida entradas
  const entries = await listEntries(zipPath);
  if (entries.length === 0) return { ok: false, error: 'petpack vazio' };
  if (entries.length > MAX_ENTRIES) {
    return { ok: false, error: 'demasiados ficheiros no petpack' };
  }

  const files = entries.filter((e) => !e.endsWith('/'));
  if (!files.includes('pet.json') && !files.some((f) => f.endsWith('/pet.json'))) {
    return { ok: false, error: 'pet.json nao encontrado' };
  }
  for (const f of files) {
    if (!safeEntryName(f)) {
      return { ok: false, error: `entrada insegura: ${f}` };
    }
    if (!ALLOWED_EXT.has(path.extname(f).toLowerCase())) {
      return { ok: false, error: `tipo nao permitido: ${f}` };
    }
  }

  // 2. le o pet.json (dentro de uma subpasta ou na raiz)
  const manifestEntry = files.includes('pet.json')
    ? 'pet.json'
    : files.find((f) => f.endsWith('/pet.json'))!;
  const prefix = manifestEntry.slice(0, -'pet.json'.length);
  const manifestRaw = await readEntry(zipPath, manifestEntry);

  let manifest: {
    id?: string;
    frameSize?: [number, number];
    spritesheetPath?: string;
    states?: Record<string, unknown>;
  };
  try {
    manifest = JSON.parse(manifestRaw.toString('utf8'));
  } catch {
    return { ok: false, error: 'pet.json invalido' };
  }
  if (
    !manifest.id ||
    !ID_RE.test(manifest.id) ||
    !Array.isArray(manifest.frameSize) ||
    typeof manifest.spritesheetPath !== 'string' ||
    !manifest.states?.idle
  ) {
    return { ok: false, error: 'pet.json incompleto (id/frameSize/states.idle)' };
  }

  const destDir = path.join(petsRoot, manifest.id);

  // 3. extrai so' os ficheiros com o prefixo do manifest
  fs.mkdirSync(destDir, { recursive: true });
  let total = 0;
  for (const f of files) {
    if (!f.startsWith(prefix)) continue;
    const rel = f.slice(prefix.length);
    const relDir = path.dirname(rel);
    if (relDir !== '.') fs.mkdirSync(path.join(destDir, relDir), { recursive: true });
    const buf = await readEntry(zipPath, f);
    total += buf.length;
    if (total > MAX_TOTAL_BYTES) return { ok: false, error: 'petpack demasiado grande' };
    fs.writeFileSync(path.join(destDir, rel), buf);
  }

  // 4. valida spritesheet existe
  if (!fs.existsSync(path.join(destDir, manifest.spritesheetPath))) {
    fs.rmSync(destDir, { recursive: true, force: true });
    return { ok: false, error: `falta ${manifest.spritesheetPath}` };
  }

  return { ok: true, petId: manifest.id };
}

export function removePet(petId: string): boolean {
  if (!ID_RE.test(petId)) return false;
  const dir = path.join(app.getPath('userData'), 'pets', petId);
  if (!fs.existsSync(dir)) return false;
  fs.rmSync(dir, { recursive: true, force: true });
  return true;
}

// ---- helpers yauzl -----------------------------------------------------

function openZip(zipPath: string): Promise<yauzl.ZipFile> {
  return new Promise((resolve, reject) => {
    yauzl.open(zipPath, { lazyEntries: true }, (err, zip) =>
      err || !zip ? reject(err) : resolve(zip)
    );
  });
}

async function listEntries(zipPath: string): Promise<string[]> {
  const zip = await openZip(zipPath);
  return new Promise((resolve, reject) => {
    const names: string[] = [];
    zip.on('entry', (e: yauzl.Entry) => {
      names.push(e.fileName);
      zip.readEntry();
    });
    zip.on('end', () => resolve(names));
    zip.on('error', reject);
    zip.readEntry();
  });
}

function readEntry(zipPath: string, entryName: string): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    yauzl.open(zipPath, { lazyEntries: true }, (err, zip) => {
      if (err || !zip) return reject(err);
      zip.on('entry', (e: yauzl.Entry) => {
        if (e.fileName !== entryName) {
          zip.readEntry();
          return;
        }
        if (e.uncompressedSize > MAX_FILE_BYTES) {
          return reject(new Error('ficheiro demasiado grande'));
        }
        zip.openReadStream(e, (e2, stream) => {
          if (e2 || !stream) return reject(e2);
          const chunks: Buffer[] = [];
          stream.on('data', (c: Buffer) => chunks.push(c));
          stream.on('end', () => {
            zip.close();
            resolve(Buffer.concat(chunks));
          });
          stream.on('error', reject);
        });
      });
      zip.on('end', () => reject(new Error(`entrada nao encontrada: ${entryName}`)));
      zip.on('error', reject);
      zip.readEntry();
    });
  });
}
