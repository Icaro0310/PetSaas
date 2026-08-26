// Edge function para marcar e notificar doses perdidas.
// Agendada via cron Supabase a cada 15 minutos.
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (_req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // 1. Marca doses pendentes com mais de 2h como perdidas
  await supabase.rpc('check_missed_doses')

  // 2. Busca doses recem-marcadas como perdidas (ultimos 15 min) para notificar
  const since = new Date(Date.now() - 15 * 60 * 1000).toISOString()
  const { data: missed } = await supabase
    .from('dose_logs')
    .select('id, pet_id, medication_id, scheduled_time, pets(owner_id, name), medications(name)')
    .eq('status', 'missed')
    .gte('updated_at', since)

  if (!missed || missed.length === 0) {
    return new Response(JSON.stringify({ notified: 0 }), {
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const ownerIds = new Set<string>()
  for (const m of missed) {
    const ownerId = (m.pets as any)?.owner_id
    if (ownerId) ownerIds.add(ownerId)
  }

  for (const ownerId of ownerIds) {
    const ownerMissed = missed.filter((m) => (m.pets as any)?.owner_id === ownerId)
    const titles = ownerMissed
      .map((m) => `${(m.pets as any)?.name} - ${(m.medications as any)?.name}`)
      .join(', ')

    await supabase.from('notifications_log').insert({
      user_id: ownerId,
      type: 'dose_missed',
      title: 'Dose perdida',
      body: `Dose(s) perdida(s): ${titles}`,
      data: { count: ownerMissed.length },
    })
  }

  return new Response(JSON.stringify({ notified: ownerIds.size }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
