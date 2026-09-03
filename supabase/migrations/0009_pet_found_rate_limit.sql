-- 0009_pet_found_rate_limit.sql
-- Adiciona colunas para rate limiting no notify-pet-found:
-- - finder_ip: IP de quem enviou a mensagem (para rate limit por IP)
-- - created_at: timestamp de criacao (para queries de rate limit)
--
-- Tambem adiciona expiracao de 7 dias no accept_invite (A3).

-- =========================================================================
-- 1. Adicionar colunas a pet_found_messages
-- =========================================================================
alter table pet_found_messages add column if not exists finder_ip inet;
alter table pet_found_messages add column if not exists created_at timestamptz default now();

-- Criar indice para rate limit por IP
create index if not exists idx_pet_found_messages_ip_created
  on pet_found_messages (finder_ip, created_at);

-- Criar indice para rate limit por pet
create index if not exists idx_pet_found_messages_pet_created
  on pet_found_messages (pet_id, created_at);

-- =========================================================================
-- 2. Atualizar accept_invite com expiracao de 7 dias (A3)
-- =========================================================================
-- O convite de cuidador deve expirar apos 7 dias.
-- Antes: so verificava status = 'pending'
-- Agora: verifica status = 'pending' AND invited_at > now() - 7 days
drop function if exists public.accept_invite(text);
create or replace function public.accept_invite(p_token text)
returns void
language plpgsql
security definer
as $$
begin
  update caregivers
  set caregiver_id = (select auth.jwt()->>'sub'), status = 'active', accepted_at = now()
  where invite_token = p_token
    and status = 'pending'
    and invited_at > now() - interval '7 days';
end;
$$;

-- Grant explicito: apenas utilizadores autenticados podem aceitar convites
revoke execute on function public.accept_invite(text) from anon, public;
grant execute on function public.accept_invite(text) to authenticated;
