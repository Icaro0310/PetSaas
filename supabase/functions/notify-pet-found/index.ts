// Edge Function: notify-pet-found
// Recebe mensagem de quem encontrou o pet e notifica o dono.
// Publica (sem auth) - chamada por qualquer pessoa que le o QR Code.

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

  const { data: pet } = await supabase
    .from('pets')
    .select('id, name, owner_id')
    .eq('qr_code_uuid', data.qr_code_uuid)
    .single()
  if (!pet) return new Response('Pet not found', { status: 404 })

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
