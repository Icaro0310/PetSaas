// Edge Function: subscribe
// Regista emails do website institucional na tabela waitlist.
// Publica (sem auth) - chamada pelo formulario do site estatico.
//
// Seguranca:
// - Validacao Zod com .strict() (bloqueia campos extras)
// - Rate limiting por IP (max 5 inscricoes por hora por IP)
// - CORS com allowlist de origens (site GitHub Pages, pages.dev, localhost)
// - Email duplicado devolve success:true (nao revela se o email ja existe)

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { z } from 'https://esm.sh/zod@3.23.8'

const schema = z.object({
  email: z.string().email().max(255),
  source: z.string().max(50).optional(),
}).strict()

const MAX_PER_IP_PER_HOUR = 5

const ALLOWED_ORIGINS = [
  'https://icaro0310.github.io',
  'https://petsaas.pages.dev',
  'http://127.0.0.1:8080',
  'http://localhost:8080',
]

function corsHeaders(origin: string | null): Record<string, string> {
  const allowed = origin && ALLOWED_ORIGINS.includes(origin) ? origin : ''
  return {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': allowed || ALLOWED_ORIGINS[0],
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'content-type',
    'Vary': 'Origin',
  }
}

Deno.serve(async (req) => {
  const origin = req.headers.get('origin')
  const headers = corsHeaders(origin)

  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers })
  }
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405, headers })
  }

  let body
  try {
    body = await req.json()
  } catch {
    return new Response(JSON.stringify({ error: 'Invalid JSON' }), {
      status: 400,
      headers,
    })
  }

  const parsed = schema.safeParse(body)
  if (!parsed.success) {
    return new Response(JSON.stringify({ error: 'Invalid email' }), {
      status: 400,
      headers,
    })
  }
  const data = parsed.data
  const email = data.email.trim().toLowerCase()

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // === Rate limiting por IP ===
  const clientIp = req.headers.get('x-forwarded-for')?.split(',')[0]?.trim()
    || req.headers.get('x-real-ip')
    || 'unknown'

  if (clientIp !== 'unknown') {
    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000).toISOString()
    const { count: ipCount } = await supabase
      .from('waitlist')
      .select('*', { count: 'exact', head: true })
      .gte('created_at', oneHourAgo)
      .eq('ip', clientIp)

    if (ipCount !== null && ipCount >= MAX_PER_IP_PER_HOUR) {
      return new Response(JSON.stringify({
        error: 'Rate limit exceeded: max 5 subscriptions per hour',
      }), {
        status: 429,
        headers: { ...headers, 'Retry-After': '3600' },
      })
    }
  }

  // === Inserir (deduplicado por indice unico em lower(email)) ===
  const { error } = await supabase.from('waitlist').insert({
    email,
    source: data.source ?? 'website',
    ip: clientIp !== 'unknown' ? clientIp : null,
  })

  // 23505 = unique violation: email ja inscrito. Responder success na mesma
  // para nao revelar se um email esta ou nao registado.
  if (error && error.code !== '23505') {
    console.error('waitlist insert failed:', error.code)
    return new Response(JSON.stringify({ error: 'Subscription failed' }), {
      status: 500,
      headers,
    })
  }

  return new Response(JSON.stringify({ success: true }), { headers })
})
