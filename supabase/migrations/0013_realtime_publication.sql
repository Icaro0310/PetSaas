-- 0013_realtime_publication.sql
-- A app subscreve .stream() em pets, medications e caregivers (providers).
-- As tabelas têm de pertencer à publicação supabase_realtime, senão o
-- subscribe falha com channelError. RLS aplica-se aos eventos realtime.

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public' and tablename = 'pets'
  ) then
    alter publication supabase_realtime add table pets;
  end if;

  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public' and tablename = 'medications'
  ) then
    alter publication supabase_realtime add table medications;
  end if;

  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public' and tablename = 'caregivers'
  ) then
    alter publication supabase_realtime add table caregivers;
  end if;
end $$;
