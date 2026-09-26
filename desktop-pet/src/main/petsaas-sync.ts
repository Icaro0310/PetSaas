import { app } from 'electron';
import * as path from 'path';
import * as fs from 'fs';
import * as https from 'https';
import { getSettings } from './state';

// Mesmas chaves publicas do cliente Flutter (constants.dart) — protegidas
// por RLS. NUNCA service_role aqui.
const SUPABASE_URL = 'https://dotplnbakltelacsxvjz.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable__Pp5qzGJ2HlZPPD1NEdPSg_ZCCA9I9x';

export interface SaasPet {
  id: string;
  name: string;
  species: string;
  breed: string | null;
  photo_url: string | null;
}

export interface SyncResult {
  ok: boolean;
  pets?: SaasPet[];
  photosSaved?: string[];
  error?: string;
}

function restGet(route: string, token: string): Promise<unknown> {
  return new Promise((resolve, reject) => {
    const req = https.request(
      `${SUPABASE_URL}/rest/v1${route}`,
      {
        headers: {
          apikey: SUPABASE_ANON_KEY,
          authorization: `Bearer ${token}`,
        },
        timeout: 15000,
      },
      (res) => {
        let out = '';
        res.on('data', (c) => (out += c));
        res.on('end', () => {
          if (res.statusCode && res.statusCode >= 400) {
            return reject(
              new Error(`Supabase ${res.statusCode}: ${out.slice(0, 200)}`)
            );
          }
          try {
            resolve(JSON.parse(out));
          } catch {
            reject(new Error('resposta invalida do Supabase'));
          }
        });
      }
    );
    req.on('timeout', () => req.destroy(new Error('timeout')));
    req.on('error', reject);
    req.end();
  });
}

function download(url: string, dest: string): Promise<void> {
  return new Promise((resolve, reject) => {
    https
      .get(url, { timeout: 30000 }, (res) => {
        if (
          res.statusCode &&
          res.statusCode >= 300 &&
          res.statusCode < 400 &&
          res.headers.location
        ) {
          res.resume();
          return download(res.headers.location, dest).then(resolve, reject);
        }
        if (res.statusCode !== 200) {
          res.resume();
          return reject(new Error(`HTTP ${res.statusCode}`));
        }
        const ws = fs.createWriteStream(dest);
        res.pipe(ws);
        ws.on('finish', () => ws.close(() => resolve()));
        ws.on('error', reject);
      })
      .on('error', reject);
  });
}

function photoExt(url: string): string {
  const ext = path.extname(new URL(url).pathname).toLowerCase();
  return ['.jpg', '.jpeg', '.png', '.webp', '.gif'].includes(ext)
    ? ext
    : '.jpg';
}

/**
 * Lista os pets do utilizador autenticado. O JWT do Clerk vai no Bearer;
 * o RLS (auth.jwt()->>'sub') filtra por owner_id — IDOR impossivel por
 * construcao: o token so' ve os pets do proprio user.
 * Guarda as fotos em userData/petsaas-cache/.
 */
export async function syncPetSaas(): Promise<SyncResult> {
  const token = getSettings().petsaasToken.trim();
  if (!token) {
    return {
      ok: false,
      error:
        'Token em falta. Cola o teu Clerk session token nas Definicoes.',
    };
  }

  let pets: SaasPet[];
  try {
    pets = (await restGet(
      '/pets?select=id,name,species,breed,photo_url&order=created_at.asc',
      token
    )) as SaasPet[];
  } catch (e) {
    return { ok: false, error: String((e as Error).message || e) };
  }

  const cacheDir = path.join(app.getPath('userData'), 'petsaas-cache');
  fs.mkdirSync(cacheDir, { recursive: true });

  const photosSaved: string[] = [];
  for (const p of pets) {
    if (!p.photo_url) continue;
    const dest = path.join(cacheDir, `${p.id}${photoExt(p.photo_url)}`);
    try {
      await download(p.photo_url, dest);
      photosSaved.push(dest);
    } catch {
      /* foto indisponivel — continua */
    }
  }

  const metaPath = path.join(cacheDir, 'pets.json');
  fs.writeFileSync(metaPath, JSON.stringify(pets, null, 2), 'utf8');

  return { ok: true, pets, photosSaved };
}
