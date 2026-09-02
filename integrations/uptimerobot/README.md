# UptimeRobot

Monitorizacao externa de uptime.

## Monitores

| Nome | URL | ID | Intervalo |
|------|-----|----|-----------|
| moonlit-pothos-c56cd4.netlify.app | `https://moonlit-pothos-c56cd4.netlify.app` | `803897084` | 300s |
| Supabase API + Auth | `https://dotplnbakltelacsxvjz.supabase.co/functions/v1/health` | `803898227` | 300s |

## API

| Campo | Valor |
|-------|-------|
| API key | Guardada em GitHub secret `UPTIMEROBOT_API_KEY` |
| Conta | Free plan (max 50 monitores, intervalo min 300s) |

## Health check endpoint

O monitor do Supabase usa a Edge Function `health` que e publica (sem auth) e retorna:
- `200 OK` com `{"status":"ok","database":"up"}` se o Postgres estiver up
- `500` se o Postgres estiver down

Isto evita o erro 401 que acontecia quando o UptimeRobot tentava aceder `/rest/v1/` sem a anon key.

## Ficheiros relacionados

| Ficheiro | Descricao |
|----------|-----------|
| `supabase/functions/health/index.ts` | Endpoint de health check |
| `.github/workflows/supabase-deploy.yml` | Deploy da function health |

## Limitacoes do plano free

- Sem custom HTTP headers nos monitores
- Intervalo minimo de 5 minutos
- Max 50 monitores
- Sem alertas por SMS (apenas email)
