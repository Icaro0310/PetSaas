-- 0016_petdesk.sql
-- PetDeskSaas online: jobs de geracao de petpack (desktop companion).
-- O desktop lista os seus jobs e descarrega o .petpack via signed URL.

create table if not exists public.pet_generation_jobs (
  id uuid primary key default gen_random_uuid(),
  user_id text not null,               -- clerk sub (auth.jwt()->>'sub')
  pet_id uuid references public.pets(id) on delete set null,
  kind text not null check (kind in ('library','custom','recolor')),
  description text,                    -- texto livre p/ 'custom'
  breed_id text,                       -- id da biblioteca p/ 'library'/'recolor'
  coat text,                           -- preset recolor (opcional)
  status text not null default 'queued'
    check (status in ('queued','running','done','failed')),
  petpack_path text,                   -- path no bucket petpacks
  error text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_pet_generation_jobs_user_created
  on public.pet_generation_jobs(user_id, created_at desc);

alter table public.pet_generation_jobs enable row level security;

-- Cada utilizador so ve e cria os seus proprios jobs (Clerk sub).
create policy "own jobs" on public.pet_generation_jobs
  for all to authenticated
  using (user_id = (select auth.jwt()->>'sub'))
  with check (user_id = (select auth.jwt()->>'sub'));

-- O update do status (queued->running->done/failed) e feito pela Edge
-- Function com service_role, que ignora RLS — por isso a policy "own
-- jobs" FOR ALL e suficiente para o cliente (select/insert).

-- ---------------------------------------------------------------------
-- STORAGE: bucket petpacks (PRIVADO)
--   library/<breed>[_<coat>].petpack  — packs pre-gerados, leitura authed
--   <user_id>/<job_id>.petpack        — outputs por user (custom futuro)
-- Escrita: apenas service_role (Edge Function / upload script). Sem
-- policies de insert/update/delete para authenticated.
-- ---------------------------------------------------------------------

insert into storage.buckets (id, name, public)
values ('petpacks', 'petpacks', false)
on conflict (id) do nothing;

drop policy if exists "Authenticated read petpacks" on storage.objects;
create policy "Authenticated read petpacks" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'petpacks'
    and (
      (storage.foldername(name))[1] = 'library'
      or (storage.foldername(name))[1] = (select auth.jwt()->>'sub')
    )
  );
