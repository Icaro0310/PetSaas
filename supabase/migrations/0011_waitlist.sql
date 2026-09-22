-- 0011_waitlist.sql
-- Tabela waitlist: inscricoes de email capturadas no website institucional.
--
-- Seguranca:
-- - RLS ativa SEM policies: anon/authenticated nao leem nem escrevem.
--   Escrita apenas via Edge Function `subscribe` (service_role).
-- - Email unico (case-insensitive) para deduplicacao.
-- - Coluna ip para rate limiting por IP na Edge Function.

create table if not exists public.waitlist (
  id bigint generated always as identity primary key,
  email text not null,
  source text not null default 'website',
  ip inet,
  created_at timestamptz not null default now()
);

-- Deduplicacao: um email so entra uma vez (independente de maiusculas)
create unique index if not exists idx_waitlist_email_lower
  on public.waitlist (lower(email));

-- Indice para rate limit por IP na Edge Function
create index if not exists idx_waitlist_ip_created
  on public.waitlist (ip, created_at);

-- RLS ativa, sem policies = tabela fechada para anon e authenticated.
-- O service_role (Edge Function) faz bypass da RLS.
alter table public.waitlist enable row level security;
