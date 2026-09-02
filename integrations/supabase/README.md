# Supabase

Backend principal do PetCare: Postgres, Storage, Edge Functions, RLS e Realtime.

## Configuracao

| Campo | Valor |
|-------|-------|
| Project ref | `dotplnbakltelacsxvjz` |
| Org ID | `zzrgrdqhulsuogokfnoa` |
| Regiao | Central EU (Frankfurt) |
| URL | `https://dotplnbakltelacsxvjz.supabase.co` |
| Anon key | `sb_publishable__Pp5qzGJ2HlZPPD1NEdPSg_ZCCA9I9x` |

## Ficheiros relacionados

| Ficheiro | Descricao |
|----------|-----------|
| `lib/core/services/supabase_service.dart` | Cliente Supabase + sync profile |
| `lib/config/constants.dart` | URL e anon key |
| `supabase/config.toml` | Config do CLI |
| `supabase/migrations/` | Migrations SQL (0001-0008) |
| `supabase/functions/` | Edge Functions |
| `.github/workflows/supabase-deploy.yml` | CI/CD de migrations e functions |
| `.github/workflows/keep-supabase-active.yml` | Keep-alive via GitHub Actions |

## Migrations

| # | Nome | Descricao |
|---|------|-----------|
| 0001 | init | Schema completo + RLS |
| 0002 | cron_dose_missed | Cron job para doses perdidas |
| 0003 | caregiver_pets_rls | RLS para caregivers verem pets |
| 0004-0006 | keep_alive | Keep-alive do Postgres |
| 0007 | clerk_auth | Migracao uuid->text para Clerk user IDs |
| 0008 | jwt_rls | RLS policies com `auth.jwt()->>'sub'` |

## Edge Functions

| Nome | Descricao |
|------|-----------|
| `notify-pet-found` | Notifica dono quando alguem encontra o pet |
| `notify-dose-missed` | Notifica doses perdidas |
| `clerk-webhook` | Sincroniza users Clerk -> Supabase profiles |
| `health` | Endpoint publico de health check (UptimeRobot) |

## Keep-alive

- `pg_cron` as 11:00 e 23:00 UTC
- Pruning de cron logs as 03:00 UTC
- GitHub Actions ping a cada 6 horas
- Commit keep-alive nos dias 1 e 15 de cada mes

## Comandos uteis

```bash
supabase db push              # Aplicar migrations
supabase functions deploy X   # Deploy edge function
supabase db query --linked "SQL"  # Query remota
```
