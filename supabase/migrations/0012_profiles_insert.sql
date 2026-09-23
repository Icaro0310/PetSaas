-- 0012_profiles_insert.sql
-- A tabela profiles nunca teve policy de INSERT: o perfil era criado pelo
-- trigger on_auth_user_created, que so dispara para Supabase Auth nativo.
-- Utilizadores Clerk criam o perfil via upsert na app, o que exige INSERT.

create policy "Users can insert own profile" on profiles
  for insert to authenticated
  with check ((select auth.jwt()->>'sub') = id);
