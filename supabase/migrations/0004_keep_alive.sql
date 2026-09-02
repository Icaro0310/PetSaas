-- Tabela e cron para manter o projeto Supabase Free ativo.
-- O Supabase pausa projetos Free apos ~7 dias sem atividade na base de dados.
-- Esta migration cria uma tabela pequena, uma politica publica de leitura
-- e um job pg_cron que faz uma query a cada 6 horas.

create table if not exists public.keep_alive (
  id int primary key,
  updated_at timestamptz default now()
);

-- Garante uma unica linha; o cron apenas faz SELECT, mas mantem o timestamp atual.
insert into public.keep_alive (id) values (1)
  on conflict (id) do update set updated_at = now();

-- Permite leitura anonima para que GitHub Actions possa pingar sem segredo.
alter table public.keep_alive enable row level security;

drop policy if exists "Anon can read keep_alive" on public.keep_alive;
create policy "Anon can read keep_alive" on public.keep_alive
  for select to anon
  using (true);

-- Job pg_cron: query leve a cada 6 horas para gerar atividade na base.
select cron.schedule(
  'keep-alive-ping',
  '0 */6 * * *',
  'select 1 from public.keep_alive limit 1;'
);
