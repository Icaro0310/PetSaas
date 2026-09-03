-- 0010_fix_notify_dose_missed_auth.sql
-- Corrige a autorizacao do cron notify-dose-missed.
--
-- Problema: a migration 0002 embutia a publishable key (anon key)
-- diretamente no SQL do cron, expondo-a no schema public.
--
-- Solucao: usar uma funcao SECURITY DEFINER que le a URL e a key
-- de configuracoes do Supabase (pg_catalog.pg_settings ou current_setting)
-- em vez de hardcodar no SQL.
--
-- Alternativamente, usamos a funcao net.http_post com headers
-- dinamicos baseados em current_setting('app.supabase_anon_key').

-- Remover o cron antigo que tem a key hardcoded
select cron.unschedule('notify-dose-missed-cron') where exists (
  select 1 from cron.job where jobname = 'notify-dose-missed-cron'
);

-- Criar funcao wrapper que chama a edge function sem expor a key no SQL
create or replace function public.call_notify_dose_missed()
returns void
language plpgsql
security definer
as $$
declare
  v_url text := 'https://dotplnbakltelacsxvjz.supabase.co/functions/v1/notify-dose-missed';
  v_key text;
begin
  -- Tenta ler a anon key de uma setting customizada.
  -- Para configurar: ALTER DATABASE current_database() SET app.supabase_anon_key = 'sb_publishable__...';
  -- Se nao estiver configurada, usa uma string vazia (a EF rejeitara 401).
  v_key := current_setting('app.supabase_anon_key', true);

  if v_key is null or v_key = '' then
    -- Fallback: a key publishable e publica por design (protegida por RLS).
    -- Mas nao a hardcodamos aqui; o admin deve configura-la via ALTER DATABASE.
    raise notice 'app.supabase_anon_key nao configurada. Definir com: ALTER DATABASE current_database() SET app.supabase_anon_key = ''sb_publishable__...''';
    return;
  end if;

  perform net.http_post(
    url := v_url,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || v_key
    ),
    body := '{}'::jsonb
  );
end;
$$;

-- Revogar acesso publico a funcao
revoke execute on function public.call_notify_dose_missed() from anon, public;
grant execute on function public.call_notify_dose_missed() to service_role;

-- Reagendar o cron usando a funcao wrapper (sem key no SQL)
select cron.schedule(
  'notify-dose-missed-cron',
  '*/15 * * * *',
  $$ select public.call_notify_dose_missed(); $$
);
