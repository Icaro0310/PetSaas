// Edge Function: petdesk-generate
// PetDeskSaas online: cria jobs de geracao de petpack (o companion de
// desktop) e devolve signed URL para download quando pronto.
//
//   POST /petdesk-generate  {kind, pet_id?, breed_id?, coat?, description?}
//     -> 202 { job_id, status }
//   GET  /petdesk-generate?job_id=<uuid>
//     -> { status, petpack_url? , error? }
//   GET  /petdesk-generate
//     -> { jobs: [...] }  (ultimos 20 do proprio user)
//
// Resolucao nesta fase (ver HANDOFF_ONLINE.md §4.3):
//   library -> petpack pre-gerado em petpacks/library/<breed>.petpack
//   recolor -> variante pre-gerada petpacks/library/<breed>__<coat>.petpack
//   custom  -> 501 (pipeline Python/IA pesado fica para worker dedicado)
//
// Seguranca: Clerk JWT (sub) via auth.getUser(); IDOR de pet_id feito
// pelo proprio RLS (user-scoped client devolve 0 linhas se nao for dono);
// rate limit 5 jobs/dia; storage privado; signed URL 1h.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { z } from 'https://esm.sh/zod@3.23.8'

const ID_RE = /^[a-z0-9][a-z0-9_-]{0,63}$/
const COATS = [
  'caramelo',
  'chocolate',
  'preto',
  'branco',
  'cinza',
  'creme',
  'dourado',
  'vermelho',
] as const
const MAX_JOBS_PER_DAY = 5
const BUCKET = 'petpacks'
const SIGNED_URL_TTL_SECONDS = 3600

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
}

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...cors, 'Content-Type': 'application/json' },
  })
}

const schema = z
  .object({
    kind: z.enum(['library', 'custom', 'recolor']),
    pet_id: z.string().uuid().optional(),
    breed_id: z.string().regex(ID_RE).optional(),
    coat: z.enum(COATS).optional(),
    description: z.string().min(1).max(300).optional(),
  })
  .strict()
  .superRefine((d, ctx) => {
    if (d.kind === 'library' && !d.breed_id) {
      ctx.addIssue({ code: 'custom', message: 'breed_id obrigatorio para library' })
    }
    if (d.kind === 'recolor' && (!d.breed_id || !d.coat)) {
      ctx.addIssue({
        code: 'custom',
        message: 'breed_id e coat obrigatorios para recolor',
      })
    }
    if (d.kind === 'custom' && !d.description) {
      ctx.addIssue({ code: 'custom', message: 'description obrigatoria para custom' })
    }
  })

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors })

  const authHeader = req.headers.get('Authorization')
  if (!authHeader) return json({ error: 'Unauthorized' }, 401)

  // Cliente com o JWT do user — as queries respeitam RLS.
  const userClient = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    { global: { headers: { Authorization: authHeader } } },
  )
  const {
    data: { user },
  } = await userClient.auth.getUser()
  if (!user) return json({ error: 'Unauthorized' }, 401)
  const userId = user.id // clerk sub

  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  )

  if (req.method === 'GET') {
    const jobId = new URL(req.url).searchParams.get('job_id')
    if (!jobId) {
      const { data: jobs } = await userClient
        .from('pet_generation_jobs')
        .select('id,kind,status,pet_id,breed_id,coat,petpack_path,error,created_at')
        .order('created_at', { ascending: false })
        .limit(20)
      return json({ jobs: jobs ?? [] })
    }
    if (!z.string().uuid().safeParse(jobId).success) {
      return json({ error: 'job_id invalido' }, 400)
    }
    // RLS garante que so' o dono ve o job.
    const { data: job } = await userClient
      .from('pet_generation_jobs')
      .select('*')
      .eq('id', jobId)
      .maybeSingle()
    if (!job) return json({ error: 'job nao encontrado' }, 404)

    const out: Record<string, unknown> = {
      job_id: job.id,
      status: job.status,
      error: job.error,
    }
    if (job.status === 'done' && job.petpack_path) {
      const { data: signed, error } = await admin.storage
        .from(BUCKET)
        .createSignedUrl(job.petpack_path, SIGNED_URL_TTL_SECONDS)
      if (error || !signed) {
        return json({ error: 'falha ao criar signed URL' }, 500)
      }
      out.petpack_url = signed.signedUrl
    }
    return json(out)
  }

  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405)

  let body
  try {
    body = await req.json()
  } catch {
    return json({ error: 'Invalid JSON' }, 400)
  }
  const parsed = schema.safeParse(body)
  if (!parsed.success) {
    return json({ error: parsed.error.issues }, 400)
  }
  const data = parsed.data

  // custom exige o pipeline Python (rembg + bake) — nao corre em Deno.
  if (data.kind === 'custom') {
    return json(
      { error: "kind 'custom' ainda nao suportado — usa 'library' ou 'recolor'" },
      501,
    )
  }

  // Rate limit: max 5 jobs por dia por user (conta os do proprio user).
  const dayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString()
  const { count } = await userClient
    .from('pet_generation_jobs')
    .select('*', { count: 'exact', head: true })
    .gte('created_at', dayAgo)
  if ((count ?? 0) >= MAX_JOBS_PER_DAY) {
    return new Response(
      JSON.stringify({ error: 'Rate limit exceeded: max 5 jobs per day' }),
      { status: 429, headers: { ...cors, 'Content-Type': 'application/json', 'Retry-After': '86400' } },
    )
  }

  // IDOR: pet_id tem de pertencer ao user (RLS devolve 0 linhas senao).
  if (data.pet_id) {
    const { data: pet } = await userClient
      .from('pets')
      .select('id')
      .eq('id', data.pet_id)
      .maybeSingle()
    if (!pet) return json({ error: 'pet nao encontrado' }, 404)
  }

  const petpackPath =
    data.kind === 'library'
      ? `library/${data.breed_id}.petpack`
      : `library/${data.breed_id}__${data.coat}.petpack`

  // O pack tem de existir no bucket (pre-gerado offline).
  const dir = petpackPath.slice(0, petpackPath.lastIndexOf('/'))
  const file = petpackPath.slice(petpackPath.lastIndexOf('/') + 1)
  const { data: listing } = await admin.storage.from(BUCKET).list(dir)
  if (!listing?.some((f) => f.name === file)) {
    return json({ error: `petpack indisponivel: ${petpackPath}` }, 404)
  }

  const { data: job, error: insErr } = await userClient
    .from('pet_generation_jobs')
    .insert({
      user_id: userId,
      pet_id: data.pet_id ?? null,
      kind: data.kind,
      description: data.description ?? null,
      breed_id: data.breed_id ?? null,
      coat: data.coat ?? null,
      status: 'done',
      petpack_path: petpackPath,
    })
    .select('id,status')
    .single()
  if (insErr || !job) {
    return json({ error: 'falha ao criar job' }, 500)
  }

  return json({ job_id: job.id, status: job.status }, 202)
})
