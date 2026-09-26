# PetDeskSaas — Handoff para implementação online (outro Devin space)

> **Contexto para o agente**: este documento é o prompt completo de
> continuação. Lê `desktop-pet/` no repo e o `AGENTS.md` na raiz antes
> de codar. O ciclo plano → review → implementação → testes → auto-review
> é obrigatório.

---

## 1. O que é o projeto

**PetSaas** é uma app Flutter/Supabase de gestão de pets (Clerk auth,
migrations em `supabase/migrations/`, Edge Functions em
`supabase/functions/`).

**PetDeskSaas** é o companion de desktop (Windows, Electron) que vive em
`desktop-pet/`: um pet animado pixel-art que anda no ecrã do utilizador,
reage a interações e sincroniza com o perfil PetSaas real.

## 2. O que já existe (não reimplementar)

### Desktop app — `desktop-pet/` — M0..M6 FEITO

| Milestone | Implementado |
|---|---|
| M0 | Janela transparente/frameless/always-on-top/skipTaskbar, flipbook sprite renderer |
| M1 | MotionEngine: gravidade, bounce, drag/drop com throw, clamp, stroll, gaze |
| M2 | Click→waving, hover→petted, dblclick→Pomodoro 25min, idle 60s→sleeping, menu direito, tray |
| M3 | `src/main/state.ts` (settings.json persistente), control panel, pet loader |
| M4 | `.petpack` installer (ZIP seguro, anti-traversal), electron-builder → `release/PetDeskSaas Setup 0.1.0.exe` + portable |
| M5 | `src/main/control-server.ts` (127.0.0.1 + Bearer token por sessão, escreve `userData/petdesk-mcp.json`) + `mcp/petdesk-mcp.js` (MCP stdio sem deps, 9 tools) |
| M6 | `src/main/petsaas-sync.ts`: `GET /rest/v1/pets?select=id,name,species,breed,photo_url` com Clerk JWT → RLS filtra por owner |

### Pipeline de assets — `desktop-pet/tools/`

- `gen_pet_pollinations.py` — gera frames via Pollinations.ai (grátis, sem key) → rembg → pixelate → quantize 16 cores → sheet
- `bake_breathe.py` — deriva os 13 estados de stills canónicas via sprite-gen breathe/wiggle/hop (mesma arte = consistência total)
- `gen_library.py` — biblioteca de raças: 20 cães + 11 gatos (inclui SRD caramelo/preto/branco), 12 gerações por raça, output em `pets/library/<id>/`
- `recolor.py` — palette-swap pixel-exato: `--coat caramelo|preto|...`, `--to "#RRGGBB"`, `--from-photo` (extrai cor dominante da foto real)

### Formato .petpack (CONTRATO — não mudar sem atualizar o desktop)

ZIP contendo na raiz (ou numa subpasta única):
- `pet.json` — manifesto (schema abaixo)
- `spritesheet.webp` — sheet RGBA, N linhas × M colunas de células `frameSize`
- `tray.png` — ícone 32×32

```json
{
  "id": "labrador",                    // /^[a-z0-9][a-z0-9_-]{0,63}$/
  "displayName": "Labrador",
  "species": "dog",                    // "dog" | "cat"
  "spritesheetPath": "spritesheet.webp",
  "frameSize": [48, 48],
  "states": {                          // linha = estado, frames na linha
    "idle":     {"row": 0, "frames": 12, "fps": 5},
    "walking":  {"row": 1, "frames": 4,  "fps": 7},
    "running":  {"row": 2, "frames": 4,  "fps": 12},
    "sleeping": {"row": 3, "frames": 12, "fps": 4},
    "waving":   {"row": 4, "frames": 18, "fps": 8},
    "petted":   {"row": 5, "frames": 12, "fps": 6},
    "eating":   {"row": 6, "frames": 6,  "fps": 5},
    "playing":  {"row": 7, "frames": 8,  "fps": 7},
    "thinking": {"row": 8, "frames": 6,  "fps": 4},
    "jumping":  {"row": 9, "frames": 8,  "fps": 9},
    "alert":    {"row": 10,"frames": 18, "fps": 10},
    "sad":      {"row": 11,"frames": 6,  "fps": 4},
    "grooming": {"row": 12,"frames": 6,  "fps": 5}
  },
  "reactionMap": { "idle":"idle", "held":"alert", "falling":"alert",
    "success":"jumping", "error":"sad", "waving":"waving",
    "sleeping":"sleeping", "walking":"walking", "petted":"petted", ... },
  "speech": { "pt": {"waving":["Au au!"],...}, "en": {...} }
}
```

Regras do validador (`src/main/petpack.ts`): só `.json/.webp/.png/.gif`,
sem path traversal, `states.idle` obrigatório, `frameSize` par, sheet
deve existir no zip.

## 3. Stack e identidades partilhadas

- Supabase: `https://dotplnbakltelacsxvjz.supabase.co`
- Publishable key (pública, está em `lib/config/constants.dart`):
  `sb_publishable__Pp5qzGJ2HlZPPD1NEdPSg_ZCCA9I9x`
- Auth: **Clerk** — JWT vai em `Authorization: Bearer`; RLS usa
  `auth.jwt()->>'sub'` (migration 0008). NUNCA `auth.uid()` em policies novas.
- Tabela `pets`: `id, owner_id (clerk user id), name, species, breed,
  photo_url, ...`
- Bucket `pet_photos`: público para leitura.
- Proibições do AGENTS.md: sem `service_role` em cliente, sem secrets em
  migrations, Zod em Edge Functions, rate limit em endpoints públicos.

## 4. O que FALTA — o trabalho deste agente

### 4.1 Migration `0011_petdesk.sql`

```sql
-- tabela de jobs de geração de petpack
create table pet_generation_jobs (
  id uuid primary key default gen_random_uuid(),
  user_id text not null,               -- clerk sub
  pet_id uuid references pets(id) on delete set null,
  kind text not null check (kind in ('library','custom','recolor')),
  description text,                    -- texto livre p/ 'custom'
  breed_id text,                       -- id da biblioteca p/ 'library'/'recolor'
  coat text,                           -- preset recolor (opcional)
  status text not null default 'queued'
    check (status in ('queued','running','done','failed')),
  petpack_path text,                   -- path no bucket petpacks
  error text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
alter table pet_generation_jobs enable row level security;
create policy "own jobs" on pet_generation_jobs
  for all using (user_id = auth.jwt()->>'sub');
-- bucket 'petpacks': PRIVADO, policy de leitura por prefixo = user_id
```

### 4.2 Edge Function `petdesk-generate`

```
POST /petdesk-generate
Authorization: Bearer <clerk JWT>
{
  "kind": "library" | "recolor" | "custom",
  "pet_id"?: uuid,          // p/ herdar nome/foto do pet real
  "breed_id"?: string,      // p/ library/recolor
  "coat"?: string,          // preset recolor
  "description"?: string    // p/ custom (<=300 chars)
}
→ 202 { "job_id": uuid }

GET /petdesk-generate?job_id=...   (ou lista dos próprios jobs)
→ { "status": "done", "petpack_url": "<signed url>" }
```

Requisitos: Zod validation, rate limit (ex: 5 jobs/dia por user),
só pode referenciar `pet_id` próprio (IDOR check via RLS).

### 4.3 Geração do petpack — decisão de implementação

O pipeline pesado (rembg, PIL, breathe) é **Python** — Edge Functions
correm Deno. Opções por ordem de esforço:

1. **library/recolor sem worker** (recomendado para já): os petpacks da
   biblioteca são **pré-gerados offline** e fazem upload para o bucket
   `petpacks/library/<breed_id>.petpack` (público-ler ou signed). O job
   `library`/`recolor` resolve server-side quase instantaneamente.
   O `recolor` pode ser feito **na Edge Function em Deno** — palette-swap
   é pura manipulação de pixels (ver `tools/recolor.py`; portar com
   `imagescript` ou WASM png/webp decoder).
2. **custom (descrição livre)**: Pollinations é só HTTPS GET — a Edge
   Function pode gerar o sprite canónico. O bake dos 13 estados exige
   port do breathe (matemática simples: squash&stretch por scanline —
   ver `sprite_gen/effects/breathe.py` no venv) OU delegar o bake ao
   cliente desktop (a app recebe o sprite canónico e bakeia localmente —
   precisa de implementar bake em JS no main process).
3. Worker externo Python (Fly.io/Cloud Run) — só se as opções acima
   não chegarem.

### 4.4 Sync no desktop (já implementado, não mexer)

`petsaas-sync.ts` já consome `/rest/v1/pets` com o JWT. Para completar o
fluxo online, o desktop precisa depois de: listar `pet_generation_jobs`
do user e descarregar `petpack_path` via signed URL → `installPetpack()`.
Fica para o space do desktop — o teu contrato é só a tabela + signed URL.

### 4.5 Web UI (site/app)

Página/secção "Desktop Pet" no PetSaas web (`website/` ou nova rota):
- Botão download do `PetDeskSaas Setup.exe` (hostear o installer em
  Storage público `downloads/` ou GitHub Releases)
- "Torna o <pet> num desktop pet": escolhe pet real → kind=library
  (raça mais próxima + recolor pela foto) ou custom (descrição)
- Lista os jobs + estado; quando done → instruções de instalação

## 5. Testes obrigatórios (responsabilidade deste agente)

- `supabase functions serve petdesk-generate` + curl:
  - sem JWT → 401
  - `pet_id` de outro user → 404/forbidden (IDOR)
  - `description` >300 chars → 400
  - 6.º job no mesmo dia → 429
- RLS: `curl` com ANON_KEY + JWT de user A não lista jobs de user B
- Storage: signed URL do petpack só acessível ao owner
- Testes unitários do validador de petpack server-side
- Contrato: pet.json gerado passa no validador do `petpack.ts`
  (replicar a lógica de validação num teste Deno/TS)

## 6. Auto-review antes de entregar

- [ ] RLS ativa em `pet_generation_jobs` com `auth.jwt()->>'sub'`
- [ ] Sem service_role nem secrets no código cliente
- [ ] Zod em todos os inputs da Edge Function
- [ ] Rate limit no endpoint de geração
- [ ] Sem console.log de tokens/PII
- [ ] Signed URL com expiração curta (ex: 1h)

## 7. Entrega

Formato do AGENTS.md: `[PR]`, `[ARQUIVOS]`, `[TESTES]`, `[PENDENTE]`.
Após alterar ficheiros: `graphify update .`
