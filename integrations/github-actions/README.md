# GitHub Actions

CI/CD e automatizacoes do repositorio.

## Workflows

| Workflow | Ficheiro | Trigger | Descricao |
|----------|----------|---------|-----------|
| Supabase Deploy | `supabase-deploy.yml` | push em `supabase/` | Aplica migrations + deploy edge functions |
| Keep Supabase Active | `keep-supabase-active.yml` | schedule (6h) | Ping ao Supabase para evitar pausa |
| Weekly Report | `weekly-report.yml` | schedule (Dom 10:00 UTC) | Relatorio por email via MailerSend |
| Setup Supabase Auth | `setup-supabase-auth.yml` | manual | Config inicial do auth |

## GitHub Secrets

| Secret | Usado por |
|--------|-----------|
| `SUPABASE_ACCESS_TOKEN` | supabase-deploy, keep-supabase-active |
| `SUPABASE_PROJECT_REF` | supabase-deploy |
| `SUPABASE_URL` | keep-supabase-active |
| `SUPABASE_ANON_KEY` | keep-supabase-active |
| `MAILERSEND_SMTP_HOST` | weekly-report |
| `MAILERSEND_SMTP_PORT` | weekly-report |
| `MAILERSEND_SMTP_USER` | weekly-report |
| `MAILERSEND_SMTP_PASSWORD` | weekly-report |
| `MAILERSEND_FROM_DOMAIN` | weekly-report |
| `MAILERSEND_TO_EMAIL` | weekly-report |
| `MAILERSEND_API_TOKEN` | (nao usado atualmente) |
| `GMAIL_USERNAME` | (legado, nao usado) |
| `UPTIMEROBOT_API_KEY` | (guardado para uso futuro) |

## Ficheiros relacionados

| Ficheiro | Descricao |
|----------|-----------|
| `.github/workflows/*.yml` | Todos os workflows |
| `.gitignore` | Ignora build/, .dart_tool/, etc. |

## Repositorio

- URL: `https://github.com/Icaro0310/PetSaas`
- Branch principal: `main`
- Commits usam Co-Authored-By do Devin
