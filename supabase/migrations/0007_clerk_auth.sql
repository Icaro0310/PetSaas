-- 0007_clerk_auth.sql
-- Migra autenticacao de Supabase Auth para Clerk.
-- User IDs passam a ser text (Clerk user IDs: user_xxx) em vez de uuid.
-- RLS policies passam a usar clerk_user_id() em vez de auth.uid().

-- =========================================================================
-- 1. Funcao helper: retorna o user ID do Clerk a partir do JWT
-- =========================================================================
create or replace function public.clerk_user_id()
returns text
language sql
stable
as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::text;
$$;

-- =========================================================================
-- 2. Remover TODAS as policies existentes em TODAS as tabelas
-- =========================================================================
-- profiles
drop policy if exists "Users can view own profile" on profiles;
drop policy if exists "Users can update own profile" on profiles;

-- pets
drop policy if exists "Owners can CRUD own pets" on pets;
drop policy if exists "Caregivers can view assigned pets" on pets;

-- medications
drop policy if exists "Owners can manage medications" on medications;
drop policy if exists "Caregivers can view medications" on medications;
drop policy if exists "Caregivers can manage doses" on medications;

-- dose_logs
drop policy if exists "Owners and caregivers can manage dose_logs" on dose_logs;
drop policy if exists "Owners and caregivers can view dose logs" on dose_logs;

-- caregivers
drop policy if exists "Owners can manage caregivers" on caregivers;
drop policy if exists "Caregivers can view their assignments" on caregivers;

-- pet_found_messages
drop policy if exists "Owners can view messages for their pets" on pet_found_messages;
drop policy if exists "Owners can view found messages" on pet_found_messages;

-- subscriptions
drop policy if exists "Users can view own subscription" on subscriptions;
drop policy if exists "Users can upsert own subscription" on subscriptions;
drop policy if exists "Users can update own subscription" on subscriptions;

-- notifications_log
drop policy if exists "Users can view own notifications" on notifications_log;

-- user_devices
drop policy if exists "Users can manage own devices" on user_devices;

-- storage.objects
drop policy if exists "Owners can upload pet photos" on storage.objects;
drop policy if exists "Public can read pet photos" on storage.objects;

-- =========================================================================
-- 3. Remover TODAS as foreign key constraints
-- =========================================================================
alter table profiles drop constraint if exists profiles_id_fkey;
alter table pets drop constraint if exists pets_owner_id_fkey;
alter table caregivers drop constraint if exists caregivers_owner_id_fkey;
alter table caregivers drop constraint if exists caregivers_caregiver_id_fkey;
alter table dose_logs drop constraint if exists dose_logs_given_by_fkey;
alter table subscriptions drop constraint if exists subscriptions_user_id_fkey;
alter table notifications_log drop constraint if exists notifications_log_user_id_fkey;
alter table user_devices drop constraint if exists user_devices_user_id_fkey;

-- =========================================================================
-- 4. Alterar tipos de colunas: uuid -> text (idempotente)
-- =========================================================================
alter table profiles alter column id type text using id::text;
alter table pets alter column owner_id type text using owner_id::text;
alter table caregivers alter column owner_id type text using owner_id::text;
alter table caregivers alter column caregiver_id type text using caregiver_id::text;
alter table dose_logs alter column given_by type text using given_by::text;
alter table subscriptions alter column user_id type text using user_id::text;
alter table notifications_log alter column user_id type text using user_id::text;
alter table user_devices alter column user_id type text using user_id::text;

-- =========================================================================
-- 5. Recriar foreign key constraints
-- =========================================================================
alter table pets add constraint pets_owner_id_fkey
  foreign key (owner_id) references profiles(id) on delete cascade;

alter table caregivers add constraint caregivers_owner_id_fkey
  foreign key (owner_id) references profiles(id) on delete cascade;
alter table caregivers add constraint caregivers_caregiver_id_fkey
  foreign key (caregiver_id) references profiles(id) on delete set null;

alter table dose_logs add constraint dose_logs_given_by_fkey
  foreign key (given_by) references profiles(id) on delete set null;

alter table subscriptions add constraint subscriptions_user_id_fkey
  foreign key (user_id) references profiles(id) on delete cascade;

alter table notifications_log add constraint notifications_log_user_id_fkey
  foreign key (user_id) references profiles(id) on delete cascade;

alter table user_devices add constraint user_devices_user_id_fkey
  foreign key (user_id) references profiles(id) on delete cascade;

-- =========================================================================
-- 6. Recriar RLS policies com clerk_user_id()
-- =========================================================================
create policy "Users can view own profile" on profiles
  for select using (clerk_user_id() = id);
create policy "Users can update own profile" on profiles
  for update using (clerk_user_id() = id);

create policy "Owners can CRUD own pets" on pets
  for all using (clerk_user_id() = owner_id);

create policy "Caregivers can view assigned pets" on pets
  for select using (
    clerk_user_id() in (
      select caregiver_id from caregivers
      where pet_id = pets.id and status = 'active'
    )
  );

create policy "Owners can manage medications" on medications
  for all using (
    clerk_user_id() in (select owner_id from pets where id = medications.pet_id)
  );

create policy "Caregivers can view medications" on medications
  for select using (
    clerk_user_id() in (
      select caregiver_id from caregivers
      where pet_id = medications.pet_id and status = 'active'
    )
  );

create policy "Owners and caregivers can manage dose_logs" on dose_logs
  for all using (
    clerk_user_id() in (select owner_id from pets where id = dose_logs.pet_id)
    or clerk_user_id() in (
      select caregiver_id from caregivers
      where pet_id = dose_logs.pet_id and status = 'active'
    )
  );

create policy "Owners can manage caregivers" on caregivers
  for all using (clerk_user_id() = owner_id);
create policy "Caregivers can view their assignments" on caregivers
  for select using (clerk_user_id() = caregiver_id);

create policy "Owners can view found messages" on pet_found_messages
  for all using (
    clerk_user_id() in (select owner_id from pets where id = pet_found_messages.pet_id)
  );

create policy "Users can view own subscription" on subscriptions
  for select using (clerk_user_id() = user_id);
create policy "Users can upsert own subscription" on subscriptions
  for insert with check (clerk_user_id() = user_id);
create policy "Users can update own subscription" on subscriptions
  for update using (clerk_user_id() = user_id);

create policy "Users can view own notifications" on notifications_log
  for select using (clerk_user_id() = user_id);

create policy "Users can manage own devices" on user_devices
  for all using (clerk_user_id() = user_id);

-- Storage policies
create policy "Owners can upload pet photos" on storage.objects
  for insert with check (
    bucket_id = 'pet_photos' and clerk_user_id() is not null
  );
create policy "Public can read pet photos" on storage.objects
  for select using (bucket_id = 'pet_photos');

-- =========================================================================
-- 7. Atualizar funcoes que usavam auth.uid() ou uuid para user_id
-- =========================================================================
drop function if exists public.mark_dose_given(uuid, uuid, text, text);
create or replace function public.mark_dose_given(
  p_dose_id uuid,
  p_user_id text,
  p_photo_url text default null,
  p_notes text default null
)
returns void
language plpgsql
security definer
as $$
begin
  update dose_logs
  set given_at = now(), given_by = p_user_id, status = 'given',
      photo_url = coalesce(p_photo_url, photo_url), notes = coalesce(p_notes, notes)
  where id = p_dose_id and status = 'pending';
end;
$$;

drop function if exists public.mark_dose(uuid, uuid, text);
drop function if exists public.mark_dose(uuid, text, text);
create or replace function public.mark_dose(
  p_dose_id uuid,
  p_user_id text,
  p_status text default 'given'
)
returns void
language plpgsql
security definer
as $$
begin
  update dose_logs
  set given_at = now(), given_by = p_user_id, status = p_status,
      updated_at = now()
  where id = p_dose_id;
end;
$$;

drop function if exists public.accept_invite(uuid);
drop function if exists public.accept_invite(text);
create or replace function public.accept_invite(p_token text)
returns void
language plpgsql
security definer
as $$
begin
  update caregivers
  set caregiver_id = clerk_user_id(), status = 'active', accepted_at = now()
  where invite_token = p_token;
end;
$$;
