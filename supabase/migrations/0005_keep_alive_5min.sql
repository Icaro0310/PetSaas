-- Aumenta a frequencia do keep-alive para 5 minutos e adiciona limpeza de logs do pg_cron.
-- O objetivo e gerar atividade suficiente para o Supabase Free nunca considerar o projeto inativo,
-- sem depender exclusivamente do GitHub Actions (que pode ser desativado apos 60 dias).

-- Remove o job anterior (6h) e cria um novo a cada 5 minutos.
select cron.unschedule('keep-alive-ping');

select cron.schedule(
  'keep-alive-ping',
  '*/5 * * * *',
  'select 1 from public.keep_alive limit 1;'
);

-- O pg_cron nao limpa o historico de execucoes sozinho. Apagamos entradas com mais de 7 dias
-- para evitar crescimento excessivo da tabela cron.job_run_details.
select cron.schedule(
  'prune-cron-logs',
  '0 3 * * *',
  'delete from cron.job_run_details where end_time < now() - interval ''7 days'';'
);

-- Atualiza o timestamp da unica linha, para facil confirmacao manual de que o cron esta ativo.
update public.keep_alive set updated_at = now() where id = 1;
