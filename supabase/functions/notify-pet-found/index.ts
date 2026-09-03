// Edge Function: notify-pet-found
// Recebe mensagem de quem encontrou o pet e notifica o dono.
// Publica (sem auth) - chamada por qualquer pessoa que le o QR Code.
//
// Seguranca:
// - Validacao Zod com .strict() (bloqueia campos extras)
// - Rate limiting por IP (max 5 mensagens por hora por IP)
// - Rate limiting por pet (max 10 mensagens por 24h por pet)

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { z } from 'https://esm.sh/zod@3.23.8'

// Schema de validacao com .strict() para bloquear campos extras (ex: "role":"admin")
const schema = z.object({
  qr_code_uuid: z.string().uuid(),
  message: z.string().min(1).max(500),
  photo_url: z.string().url().optional(),
  location_lat: z.number().min(-90).max(90).optional(),
  location_lng: z.number().min(-180).max(180).optional(),
  finder_email: z.string().email().max(255).optional(),
  finder_name: z.string().max(100).optional(),
}).strict()

// Rate limiting: max 5 mensagens por hora por IP
const MAX_PER_IP_PER_HOUR = 5
// Rate limiting: max 10 mensagens por 24h por pet
const MAX_PER_PET_PER_DAY = 10

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 })
  }

  let body
  try {
    body = await req.json()
  } catch {
    return new Response(JSON.stringify({ error: 'Invalid JSON' }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  // Validacao com Zod
  const parsed = schema.safeParse(body)
  if (!parsed.success) {
    return new Response(JSON.stringify({ error: parsed.error.issues }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }
  const data = parsed.data

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // === Rate limiting por IP ===
  // Obter IP do cliente (Supabase passa via header x-forwarded-for ou x-real-ip)
  const clientIp = req.headers.get('x-forwarded-for')?.split(',')[0]?.trim()
    || req.headers.get('x-real-ip')
    || 'unknown'

  if (clientIp !== 'unknown') {
    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000).toISOString()
    const { count: ipCount } = await supabase
      .from('pet_found_messages')
      .select('*', { count: 'exact', head: true })
      .gte('created_at', oneHourAgo)
      .eq('finder_ip', clientIp)

    if (ipCount !== null && ipCount >= MAX_PER_IP_PER_HOUR) {
      return new Response(JSON.stringify({
        error: 'Rate limit exceeded: max 5 messages per hour per IP',
      }), {
        status: 429,
        headers: {
          'Content-Type': 'application/json',
          'Retry-After': '3600',
        },
      })
    }
  }

  // === Verificar se o pet existe ===
  const { data: pet } = await supabase
    .from('pets')
    .select('id, name, owner_id')
    .eq('qr_code_uuid', data.qr_code_uuid)
    .single()
  if (!pet) return new Response('Pet not found', { status: 404 })

  // === Rate limiting por pet ===
  const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString()
  const { count: petCount } = await supabase
    .from('pet_found_messages')
    .select('*', { count: 'exact', head: true })
    .eq('pet_id', pet.id)
    .gte('created_at', oneDayAgo)

  if (petCount !== null && petCount >= MAX_PER_PET_PER_DAY) {
    return new Response(JSON.stringify({
      error: 'Rate limit exceeded: max 10 messages per 24h per pet',
    }), {
      status: 429,
      headers: {
        'Content-Type': 'application/json',
        'Retry-After': '86400',
      },
    })
  }

  // === Inserir mensagem ===
  const { data: owner } = await supabase
    .from('profiles')
    .select('id')
    .eq('id', pet.owner_id)
    .single()

  await supabase.from('pet_found_messages').insert({
    pet_id: pet.id,
    qr_code_uuid: data.qr_code_uuid,
    finder_name: data.finder_name,
    finder_email: data.finder_email,
    message: data.message,
    photo_url: data.photo_url,
    location_lat: data.location_lat,
    location_lng: data.location_lng,
    finder_ip: clientIp !== 'unknown' ? clientIp : null,
  })

  if (owner) {
    await supabase.from('notifications_log').insert({
      user_id: owner.id,
      type: 'pet_found',
      title: `Encontraram ${pet.name}!`,
      body: data.message,
      data: { pet_id: pet.id },
    })

    // Push FCM (best-effort)
    const { data: devices } = await supabase
      .from('user_devices')
      .select('fcm_token')
      .eq('user_id', owner.id)

    if (devices && devices.length > 0 && Deno.env.get('FCM_SERVER_KEY')) {
      // Envio FCM via HTTP v1 exigiria OAuth; mantemos registro na notifications_log.
    }
  }

  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
