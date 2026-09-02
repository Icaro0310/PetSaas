-- Ajusta o keep-alive para 2 execucoes diarias: 11:00 e 23:00 UTC.
-- Mantem o prune diario dos logs do pg_cron.

select cron.unschedule('keep-alive-ping');

select cron.schedule(
  'keep-alive-ping',
  '0 11,23 * * *',
  'select 1 from public.keep_alive limit 1;'
);

-- O prune ja existe desde 0005; garantimos que continua ativo.
select cron.schedule(
  'prune-cron-logs',
  '0 3 * * *',
  'delete from cron.job_run_details where end_time < now() - interval ''7 days'';'
);

update public.keep_alive set updated_at = now() where id = 1;
