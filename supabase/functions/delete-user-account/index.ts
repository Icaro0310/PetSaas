// Edge Function: delete-user-account
// Apaga fisicamente todos os dados do utilizador (LGPD/GDPR compliance).
// Chamada pelo cliente autenticado. Usa service_role para cascade delete.
//
// Ordem de delecao (para evitar FK violation):
// 1. dose_logs (via medications dos pets do user)
// 2. medications (dos pets do user)
// 3. caregivers (dos pets do user)
// 4. pet_found_messages (dos pets do user)
// 5. pets (do user)
// 6. subscriptions (do user)
// 7. notifications_log (do user)
// 8. user_devices (do user)
// 9. profiles (do user)
//
// NOTA: A delecao do user no Clerk deve ser feita pelo cliente apos
// esta funcao retornar sucesso, usando a Clerk SDK.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { z } from 'https://esm.sh/zod@3.23.8'

const schema = z.object({
  user_id: z.string().min(1).max(255),
}).strict()

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 })
  }

  // Verifica autenticacao - o user so pode apagar a propria conta
  const authHeader = req.headers.get('Authorization')
  if (!authHeader) {
    return new Response('Unauthorized', { status: 401 })
  }

  const userClient = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    { global: { headers: { Authorization: authHeader } } }
  )

  // Verifica que o JWT corresponde ao user_id pedido
  const { data: { user } } = await userClient.auth.getUser()
  if (!user) {
    return new Response('Unauthorized', { status: 401 })
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

  const parsed = schema.safeParse(body)
  if (!parsed.success) {
    return new Response(JSON.stringify({ error: parsed.error.issues }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  // IDOR protection: o user so pode apagar a SUA conta
  // Com Clerk third-party auth, o JWT sub = clerk user id
  const jwtSub = user.id
  if (jwtSub !== parsed.data.user_id) {
    return new Response('Forbidden: can only delete own account', { status: 403 })
  }

  const userId = parsed.data.user_id

  // Cliente com service_role para cascade delete
  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // 1. Buscar pets do user
  const { data: pets } = await admin.from('pets').select('id').eq('owner_id', userId)
  const petIds = (pets || []).map((p: any) => p.id)

  if (petIds.length > 0) {
    // 2. Buscar medications dos pets
    const { data: meds } = await admin.from('medications').select('id').in('pet_id', petIds)
    const medIds = (meds || []).map((m: any) => m.id)

    // 3. Deletar dose_logs
    if (medIds.length > 0) {
      await admin.from('dose_logs').delete().in('medication_id', medIds)
    }

    // 4. Deletar medications
    await admin.from('medications').delete().in('pet_id', petIds)

    // 5. Deletar caregivers
    await admin.from('caregivers').delete().in('pet_id', petIds)

    // 6. Deletar pet_found_messages
    await admin.from('pet_found_messages').delete().in('pet_id', petIds)

    // 7. Deletar pets
    await admin.from('pets').delete().eq('owner_id', userId)
  }

  // 8. Deletar subscriptions
  await admin.from('subscriptions').delete().eq('user_id', userId)

  // 9. Deletar notifications_log
  await admin.from('notifications_log').delete().eq('user_id', userId)

  // 10. Deletar user_devices
  await admin.from('user_devices').delete().eq('user_id', userId)

  // 11. Deletar profile
  await admin.from('profiles').delete().eq('id', userId)

  return new Response(JSON.stringify({ success: true, deleted: true }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
