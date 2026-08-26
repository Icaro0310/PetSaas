import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req) => {
  const {
    qr_code_uuid,
    message,
    photo_url,
    location_lat,
    location_lng,
    finder_email,
    finder_name,
  } = await req.json()

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  const { data: pet } = await supabase
    .from('pets')
    .select('id, name, owner_id')
    .eq('qr_code_uuid', qr_code_uuid)
    .single()
  if (!pet) return new Response('Pet not found', { status: 404 })

  const { data: owner } = await supabase
    .from('profiles')
    .select('id')
    .eq('id', pet.owner_id)
    .single()

  await supabase.from('pet_found_messages').insert({
    pet_id: pet.id,
    qr_code_uuid,
    finder_name,
    finder_email,
    message,
    photo_url,
    location_lat,
    location_lng,
  })

  if (owner) {
    await supabase.from('notifications_log').insert({
      user_id: owner.id,
      type: 'pet_found',
      title: `Encontraram ${pet.name}!`,
      body: message,
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
