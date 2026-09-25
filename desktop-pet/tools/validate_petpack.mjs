// Replica server-side das regras do validador de petpack
// (src/main/petpack.ts) — usado para testar que os .petpack gerados
// passam no contrato do desktop. Corre com node:
//
//   node tools/validate_petpack.mjs pets/petpacks/*.petpack
//
// Exit 0 = todos validos; exit 1 = pelo menos um falhou.

import { createRequire } from 'node:module';
import path from 'node:path';

const require = createRequire(import.meta.url);
const yauzl = require('yauzl');

const ID_RE = /^[a-z0-9][a-z0-9_-]{0,63}$/;
const ALLOWED_EXT = new Set(['.json', '.webp', '.png', '.gif']);
const MAX_ENTRIES = 200;

function safeEntryName(name) {
  if (!name || name.length > 255) return false;
  if (name.includes('\0') || name.includes('\\')) return false;
  if (path.isAbsolute(name) || /^[a-zA-Z]:/.test(name) || name.startsWith('/')) {
    return false;
  }
  const parts = name.split('/');
  if (parts.some((p) => p === '..' || p === '.' || p === '')) return false;
  return true;
}

function listEntries(zipPath) {
  return new Promise((resolve, reject) => {
    yauzl.open(zipPath, { lazyEntries: true }, (err, zip) => {
      if (err || !zip) return reject(err);
      const names = [];
      zip.on('entry', (e) => {
        names.push(e.fileName);
        zip.readEntry();
      });
      zip.on('end', () => resolve(names));
      zip.on('error', reject);
      zip.readEntry();
    });
  });
}

function readEntry(zipPath, entryName) {
  return new Promise((resolve, reject) => {
    yauzl.open(zipPath, { lazyEntries: true }, (err, zip) => {
      if (err || !zip) return reject(err);
      zip.on('entry', (e) => {
        if (e.fileName !== entryName) {
          zip.readEntry();
          return;
        }
        zip.openReadStream(e, (e2, stream) => {
          if (e2 || !stream) return reject(e2);
          const chunks = [];
          stream.on('data', (c) => chunks.push(c));
          stream.on('end', () => {
            zip.close();
            resolve(Buffer.concat(chunks));
          });
          stream.on('error', reject);
        });
      });
      zip.on('end', () => reject(new Error(`missing ${entryName}`)));
      zip.readEntry();
    });
  });
}

async function validate(zipPath) {
  const entries = await listEntries(zipPath);
  if (entries.length === 0) return 'petpack vazio';
  if (entries.length > MAX_ENTRIES) return 'demasiados ficheiros';
  const files = entries.filter((e) => !e.endsWith('/'));
  if (!files.includes('pet.json') && !files.some((f) => f.endsWith('/pet.json'))) {
    return 'pet.json nao encontrado';
  }
  for (const f of files) {
    if (!safeEntryName(f)) return `entrada insegura: ${f}`;
    if (!ALLOWED_EXT.has(path.extname(f).toLowerCase())) {
      return `tipo nao permitido: ${f}`;
    }
  }
  const manifestEntry = files.includes('pet.json')
    ? 'pet.json'
    : files.find((f) => f.endsWith('/pet.json'));
  let manifest;
  try {
    manifest = JSON.parse((await readEntry(zipPath, manifestEntry)).toString('utf8'));
  } catch {
    return 'pet.json invalido';
  }
  if (
    !manifest.id ||
    !ID_RE.test(manifest.id) ||
    !Array.isArray(manifest.frameSize) ||
    typeof manifest.spritesheetPath !== 'string' ||
    !manifest.states?.idle
  ) {
    return 'pet.json incompleto (id/frameSize/states.idle)';
  }
  const prefix = manifestEntry.slice(0, -'pet.json'.length);
  if (!files.includes(prefix + manifest.spritesheetPath)) {
    return `falta ${manifest.spritesheetPath}`;
  }
  return null;
}

const files = process.argv.slice(2);
if (!files.length) {
  console.error('uso: node validate_petpack.mjs <pack.petpack> [...]');
  process.exit(2);
}

let fail = 0;
for (const f of files) {
  try {
    const err = await validate(f);
    if (err) {
      console.log(`[FAIL] ${path.basename(f)}: ${err}`);
      fail++;
    } else {
      console.log(`[ok] ${path.basename(f)}`);
    }
  } catch (e) {
    console.log(`[FAIL] ${path.basename(f)}: ${e.message}`);
    fail++;
  }
}
process.exit(fail ? 1 : 0);
