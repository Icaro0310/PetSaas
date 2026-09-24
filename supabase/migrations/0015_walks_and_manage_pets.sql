-- 0015_walks_and_manage_pets.sql
-- Feature Passeios: registo de passeios por pet (coco/xixi), varias vezes
-- ao dia, com quem registou. Permissao nova de cuidador: 'manage_pets'
-- permite inserir/editar/eliminar pets da conta do dono que o autorizou.

create table if not exists public.walks (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references public.pets(id) on delete cascade,
  walked_at timestamptz not null default now(),
  poop boolean not null default false,
  pee boolean not null default false,
  duration_minutes smallint,
  notes text,
  logged_by text not null,
  created_at timestamptz not null default now()
);

create index if not exists idx_walks_pet_time
  on public.walks(pet_id, walked_at desc);

alter table public.walks enable row level security;

-- Dono e cuidadores ativos do pet podem ver/inserir/editar/apagar passeios.
create policy "Owners and caregivers manage walks" on public.walks
  for all to authenticated
  using (
    (select auth.jwt()->>'sub') in
      (select owner_id from public.pets where id = walks.pet_id)
    or (select auth.jwt()->>'sub') in
      (select caregiver_id from public.caregivers
        where pet_id = walks.pet_id and status = 'active')
  )
  with check (
    (select auth.jwt()->>'sub') in
      (select owner_id from public.pets where id = walks.pet_id)
    or (select auth.jwt()->>'sub') in
      (select caregiver_id from public.caregivers
        where pet_id = walks.pet_id and status = 'active')
  );

-- Cuidador com permissao 'manage_pets' (concedida pelo dono na tabela
-- caregivers) pode gerir os pets desse dono: inserir, editar, eliminar.
-- O owner_id dos caregivers e a "autorizacao do Main User".
create policy "Authorized caregivers manage owner pets" on public.pets
  for all to authenticated
  using (
    exists (
      select 1 from public.caregivers c
      where c.caregiver_id = (select auth.jwt()->>'sub')
        and c.owner_id = pets.owner_id
        and c.status = 'active'
        and 'manage_pets' = any(c.permissions)
    )
  )
  with check (
    exists (
      select 1 from public.caregivers c
      where c.caregiver_id = (select auth.jwt()->>'sub')
        and c.owner_id = pets.owner_id
        and c.status = 'active'
        and 'manage_pets' = any(c.permissions)
    )
  );

-- Realtime: a lista de passeios usa .stream() na app.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and tablename = 'walks'
  ) then
    alter publication supabase_realtime add table public.walks;
  end if;
end $$;
