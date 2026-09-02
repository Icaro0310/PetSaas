# Integracoes

Cada subpasta documenta uma integracao do PetCare: configuracao, ficheiros relacionados, secrets e notas de seguranca.

| Integracao | Pasta | Resumo |
|------------|-------|--------|
| Supabase | [supabase/](supabase/) | Backend: Postgres, Storage, Edge Functions, RLS |
| Clerk | [clerk/](clerk/) | Autenticacao (substituiu Supabase Auth) |
| Sentry | [sentry/](sentry/) | Captura de erros e performance |
| PostHog | [posthog/](posthog/) | Analytics e session replay |
| Firebase | [firebase/](firebase/) | Crashlytics, FCM, Analytics |
| Netlify | [netlify/](netlify/) | Hosting do Flutter Web |
| UptimeRobot | [uptimerobot/](uptimerobot/) | Monitorizacao de uptime |
| MailerSend | [mailersend/](mailersend/) | Relatorio semanal por email |
| GitHub Actions | [github-actions/](github-actions/) | CI/CD e automatizacoes |

## Arquitetura de auth

```
Utilizador -> Clerk (login) -> JWT (com role + email)
                                |
                                v
                            Supabase (TPA integration verifica JWT)
                                |
                                v
                            RLS policies (auth.jwt()->>'sub' = user_id)
```

## Seguranca

- Chaves publicas (publishable/anon) sao seguras no cliente
- Chaves secretas (secret key, service role, SMTP password) NUNCA no cliente
- Secrets do GitHub Actions em `Settings > Secrets and variables`
- Rotacionar chaves expostas em conversas
