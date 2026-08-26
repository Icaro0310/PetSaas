-- Agenda a edge function notify-dose-missed a cada 15 minutos via pg_cron.
-- Requer a extensao pg_cron (ativada por defeito no Supabase).

-- Garante que a extensao pg_cron esta ativa
create extension if not exists pg_cron with schema extensions;

-- Remove schedule anterior se existir (idempotente)
select cron.unschedule('notify-dose-missed-cron') where exists (
  select 1 from cron.job where jobname = 'notify-dose-missed-cron'
);

-- Agenda a cada 15 minutos
select cron.schedule(
  'notify-dose-missed-cron',
  '*/15 * * * *',
  $$
  select net.http_post(
    url := 'https://dotplnbakltelacsxvjz.supabase.co/functions/v1/notify-dose-missed',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer sb_publishable__Pp5qzGJ2HlZPPD1NEdPSg_ZCCA9I9x'
    ),
    body := '{}'::jsonb
  );
  $$
);
