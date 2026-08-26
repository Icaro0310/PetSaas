-- PetCare Micro-SaaS - Esquema inicial
-- RODE NO SUPABASE SQL EDITOR EM ORDEM.
-- Todas as tabelas com RLS ativo.

-- TABELA 1: profiles
create table if not exists profiles (
  id uuid references auth.users on delete cascade primary key,
  full_name text,
  phone text,
  avatar_url text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, new.raw_user_meta_data->>'full_name');
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

alter table profiles enable row level security;
create policy "Users can view own profile" on profiles for select using (auth.uid() = id);
create policy "Users can update own profile" on profiles for update using (auth.uid() = id);

-- TABELA 2: pets
create table if not exists pets (
  id uuid default gen_random_uuid() primary key,
  owner_id uuid references profiles(id) on delete cascade not null,
  name text not null,
  species text check (species in ('dog', 'cat')) not null,
  breed text,
  birth_date date,
  weight_kg numeric(5,2),
  color text,
  photo_url text,
  description text,
  emergency_info text,
  allergies text,
  critical_meds text,
  warnings text,
  microchip_id text,
  vet_name text,
  vet_phone text,
  is_lost boolean default false,
  lost_at timestamptz,
  qr_code_uuid uuid default gen_random_uuid() unique,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table pets enable row level security;
create policy "Owners can CRUD own pets" on pets for all using (auth.uid() = owner_id);
create index if not exists idx_pets_qr on pets(qr_code_uuid);

-- Politica publica: permitir SELECT por qr_code_uuid (pagina publica)
-- Necessario para a pagina publica sem login. Usa uma funcao que permite leitura
-- apenas dos campos publicos via RPC separada (ver funcao get_public_pet).
create or replace function public.get_public_pet(p_uuid uuid)
returns table (
  name text, species text, breed text, photo_url text, description text,
  emergency_info text, allergies text, critical_meds text, warnings text,
  microchip_id text, is_lost boolean
)
language sql security definer as $$
  select name, species, breed, photo_url, description, emergency_info,
         allergies, critical_meds, warnings, microchip_id, is_lost
  from public.pets
  where qr_code_uuid = p_uuid;
$$;

-- TABELA 3: medications
create table if not exists medications (
  id uuid default gen_random_uuid() primary key,
  pet_id uuid references pets(id) on delete cascade not null,
  name text not null,
  dosage text not null,
  instructions text,
  frequency_type text check (frequency_type in ('daily', 'weekly', 'interval_hours', 'as_needed')) not null,
  frequency_value int,
  schedule_times text[],
  start_date date not null,
  end_date date,
  is_active boolean default true,
  created_at timestamptz default now()
);

alter table medications enable row level security;
create policy "Owners can manage medications" on medications for all using (
  auth.uid() in (select owner_id from pets where id = medications.pet_id)
);
create policy "Caregivers can view medications" on medications for select using (
  auth.uid() in (select caregiver_id from caregivers where pet_id = medications.pet_id and status = 'active')
);

-- TABELA 4: dose_logs
create table if not exists dose_logs (
  id uuid default gen_random_uuid() primary key,
  medication_id uuid references medications(id) on delete cascade not null,
  pet_id uuid references pets(id) on delete cascade not null,
  scheduled_time timestamptz not null,
  given_at timestamptz,
  given_by uuid references profiles(id),
  status text check (status in ('pending', 'given', 'missed', 'skipped')) default 'pending',
  photo_url text,
  notes text,
  created_at timestamptz default now()
);

alter table dose_logs enable row level security;
create policy "Owners and caregivers can manage dose_logs" on dose_logs for all using (
  auth.uid() in (
    select owner_id from pets where id = dose_logs.pet_id
    union
    select caregiver_id from caregivers where pet_id = dose_logs.pet_id and status = 'active'
  )
);
create index if not exists idx_dose_logs_pending on dose_logs(pet_id, status) where status = 'pending';
create index if not exists idx_dose_logs_scheduled on dose_logs(medication_id, scheduled_time);

-- FUNCAO: marcar dose como dada
create or replace function mark_dose_given(
  p_dose_id uuid,
  p_user_id uuid,
  p_photo_url text default null,
  p_notes text default null
)
returns void as $$
begin
  update dose_logs
  set given_at = now(), given_by = p_user_id, status = 'given',
      photo_url = coalesce(p_photo_url, photo_url), notes = coalesce(p_notes, notes)
  where id = p_dose_id and status = 'pending';
end;
$$ language plpgsql security definer;

-- FUNCAO: verificar doses perdidas
create or replace function check_missed_doses()
returns void as $$
begin
  update dose_logs set status = 'missed'
  where status = 'pending' and scheduled_time < now() - interval '2 hours';
end;
$$ language plpgsql security definer;

-- TABELA 5: caregivers
create type caregiver_status as enum ('pending', 'active', 'removed');

create table if not exists caregivers (
  id uuid default gen_random_uuid() primary key,
  pet_id uuid references pets(id) on delete cascade not null,
  owner_id uuid references profiles(id) not null,
  caregiver_id uuid references profiles(id),
  caregiver_email text not null,
  invite_token text unique default gen_random_uuid(),
  status caregiver_status default 'pending',
  permissions text[] default array['view', 'mark_dose'],
  invited_at timestamptz default now(),
  accepted_at timestamptz,
  removed_at timestamptz
);

alter table caregivers enable row level security;
create policy "Owners can manage caregivers" on caregivers for all using (auth.uid() = owner_id);
create policy "Caregivers can view their assignments" on caregivers for select using (auth.uid() = caregiver_id);

-- FUNCAO: aceitar convite
create or replace function accept_invite(p_token uuid)
returns void as $$
begin
  update caregivers
  set caregiver_id = auth.uid(), status = 'active', accepted_at = now()
  where invite_token = p_token and status = 'pending';
end;
$$ language plpgsql security definer;

-- TABELA 6: pet_found_messages
create table if not exists pet_found_messages (
  id uuid default gen_random_uuid() primary key,
  pet_id uuid references pets(id) on delete cascade not null,
  qr_code_uuid uuid not null,
  finder_name text,
  finder_email text,
  finder_phone text,
  message text not null,
  photo_url text,
  location_lat numeric(10,8),
  location_lng numeric(10,8),
  location_approx text,
  sent_at timestamptz default now(),
  read_at timestamptz,
  owner_notified boolean default false
);

alter table pet_found_messages enable row level security;
create policy "Owners can view messages for their pets" on pet_found_messages for select using (
  auth.uid() in (select owner_id from pets where id = pet_found_messages.pet_id)
);

-- TABELA 7: subscriptions
create table if not exists subscriptions (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references profiles(id) unique not null,
  status text check (status in ('active', 'cancelled', 'past_due', 'trialing')) default 'trialing',
  plan text default 'premium',
  stripe_customer_id text,
  stripe_subscription_id text,
  current_period_start timestamptz,
  current_period_end timestamptz,
  created_at timestamptz default now()
);

alter table subscriptions enable row level security;
create policy "Users can view own subscription" on subscriptions for select using (auth.uid() = user_id);
create policy "Users can upsert own subscription" on subscriptions for insert with check (auth.uid() = user_id);
create policy "Users can update own subscription" on subscriptions for update using (auth.uid() = user_id);

-- TABELA 8: notifications_log
create table if not exists notifications_log (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references profiles(id) not null,
  type text not null,
  title text not null,
  body text not null,
  data jsonb,
  read_at timestamptz,
  created_at timestamptz default now()
);

alter table notifications_log enable row level security;
create policy "Users can view own notifications" on notifications_log for select using (auth.uid() = user_id);

-- TABELA 9: user_devices (tokens FCM)
create table if not exists user_devices (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references profiles(id) on delete cascade not null,
  fcm_token text not null,
  platform text,
  created_at timestamptz default now(),
  unique (user_id, fcm_token)
);

alter table user_devices enable row level security;
create policy "Users can manage own devices" on user_devices for all using (auth.uid() = user_id);

-- STORAGE BUCKET: pet_photos
insert into storage.buckets (id, name, public)
values ('pet_photos', 'pet_photos', true)
on conflict (id) do nothing;

-- Policy: donos podem fazer upload nas proprias fotos
create policy "Owners can upload pet photos" on storage.objects
  for insert with check (
    bucket_id = 'pet_photos' and
    auth.uid() in (select owner_id from public.pets)
  );

create policy "Public can read pet photos" on storage.objects
  for select using (bucket_id = 'pet_photos');
