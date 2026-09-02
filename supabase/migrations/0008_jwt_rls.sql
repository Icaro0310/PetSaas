-- 0008_jwt_rls.sql
-- Atualiza RLS policies para usar auth.jwt()->>'sub' em vez de clerk_user_id().
-- Isto funciona com third-party auth (Clerk) configurado no Supabase.

-- =========================================================================
-- 1. Remover policies criadas em 0007
-- =========================================================================
drop policy if exists "Users can view own profile" on profiles;
drop policy if exists "Users can update own profile" on profiles;
drop policy if exists "Owners can CRUD own pets" on pets;
drop policy if exists "Caregivers can view assigned pets" on pets;
drop policy if exists "Owners can manage medications" on medications;
drop policy if exists "Caregivers can view medications" on medications;
drop policy if exists "Owners and caregivers can manage dose_logs" on dose_logs;
drop policy if exists "Owners can manage caregivers" on caregivers;
drop policy if exists "Caregivers can view their assignments" on caregivers;
drop policy if exists "Owners can view found messages" on pet_found_messages;
drop policy if exists "Users can view own subscription" on subscriptions;
drop policy if exists "Users can upsert own subscription" on subscriptions;
drop policy if exists "Users can update own subscription" on subscriptions;
drop policy if exists "Users can view own notifications" on notifications_log;
drop policy if exists "Users can manage own devices" on user_devices;
drop policy if exists "Owners can upload pet photos" on storage.objects;
drop policy if exists "Public can read pet photos" on storage.objects;

-- =========================================================================
-- 2. Recriar policies com auth.jwt()->>'sub'
-- =========================================================================
create policy "Users can view own profile" on profiles
  for select to authenticated using ((select auth.jwt()->>'sub') = id);
create policy "Users can update own profile" on profiles
  for update to authenticated using ((select auth.jwt()->>'sub') = id);

create policy "Owners can CRUD own pets" on pets
  for all to authenticated using ((select auth.jwt()->>'sub') = owner_id);

create policy "Caregivers can view assigned pets" on pets
  for select to authenticated using (
    (select auth.jwt()->>'sub') in (
      select caregiver_id from caregivers
      where pet_id = pets.id and status = 'active'
    )
  );

create policy "Owners can manage medications" on medications
  for all to authenticated using (
    (select auth.jwt()->>'sub') in (select owner_id from pets where id = medications.pet_id)
  );

create policy "Caregivers can view medications" on medications
  for select to authenticated using (
    (select auth.jwt()->>'sub') in (
      select caregiver_id from caregivers
      where pet_id = medications.pet_id and status = 'active'
    )
  );

create policy "Owners and caregivers can manage dose_logs" on dose_logs
  for all to authenticated using (
    (select auth.jwt()->>'sub') in (select owner_id from pets where id = dose_logs.pet_id)
    or (select auth.jwt()->>'sub') in (
      select caregiver_id from caregivers
      where pet_id = dose_logs.pet_id and status = 'active'
    )
  );

create policy "Owners can manage caregivers" on caregivers
  for all to authenticated using ((select auth.jwt()->>'sub') = owner_id);
create policy "Caregivers can view their assignments" on caregivers
  for select to authenticated using ((select auth.jwt()->>'sub') = caregiver_id);

create policy "Owners can view found messages" on pet_found_messages
  for all to authenticated using (
    (select auth.jwt()->>'sub') in (select owner_id from pets where id = pet_found_messages.pet_id)
  );

create policy "Users can view own subscription" on subscriptions
  for select to authenticated using ((select auth.jwt()->>'sub') = user_id);
create policy "Users can upsert own subscription" on subscriptions
  for insert to authenticated with check ((select auth.jwt()->>'sub') = user_id);
create policy "Users can update own subscription" on subscriptions
  for update to authenticated using ((select auth.jwt()->>'sub') = user_id);

create policy "Users can view own notifications" on notifications_log
  for select to authenticated using ((select auth.jwt()->>'sub') = user_id);

create policy "Users can manage own devices" on user_devices
  for all to authenticated using ((select auth.jwt()->>'sub') = user_id);

-- Storage policies
create policy "Owners can upload pet photos" on storage.objects
  for insert to authenticated with check (
    bucket_id = 'pet_photos'
  );
create policy "Public can read pet photos" on storage.objects
  for select using (bucket_id = 'pet_photos');

-- =========================================================================
-- 3. Atualizar funcao accept_invite para usar auth.jwt()->>'sub'
-- =========================================================================
drop function if exists public.accept_invite(text);
create or replace function public.accept_invite(p_token text)
returns void
language plpgsql
security definer
as $$
begin
  update caregivers
  set caregiver_id = (select auth.jwt()->>'sub'), status = 'active', accepted_at = now()
  where invite_token = p_token;
end;
$$;
