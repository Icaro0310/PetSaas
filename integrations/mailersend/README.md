# MailerSend

Envio de emails transacionais (relatorio semanal).

## Configuracao

| Campo | Valor |
|-------|-------|
| Sandbox domain | `test-z0vklo638kvl7qrx.mlsender.net` |
| SMTP host | `smtp.mailersend.net` |
| SMTP port | `587` (TLS) |
| From | `PetSaas Bot <petsaas@test-z0vklo638kvl7qrx.mlsender.net>` |
| To | `icarogalvao5@gmail.com` |

## GitHub Secrets

| Secret | Descricao |
|--------|-----------|
| `MAILERSEND_SMTP_HOST` | `smtp.mailersend.net` |
| `MAILERSEND_SMTP_PORT` | `587` |
| `MAILERSEND_SMTP_USER` | Username (sandbox domain) |
| `MAILERSEND_SMTP_PASSWORD` | Password SMTP |
| `MAILERSEND_FROM_DOMAIN` | `test-z0vklo638kvl7qrx.mlsender.net` |
| `MAILERSEND_TO_EMAIL` | `icarogalvao5@gmail.com` |
| `MAILERSEND_API_TOKEN` | API token (nao usado no SMTP) |

## Workflow

- `weekly-report.yml` corre aos Domingos as 10:00 UTC
- Recolhe estatisticas dos GitHub Actions runs dos ultimos 7 dias
- Envia relatorio HTML via `dawidd6/action-send-mail@v3`
- Teste manual confirmado: email recebido com sucesso

## Ficheiros relacionados

| Ficheiro | Descricao |
|----------|-----------|
| `.github/workflows/weekly-report.yml` | Workflow do relatorio semanal |

## Limitacoes

- Sandbox domain: max 25 destinatarios, 1000 emails/mes
- `dawidd6/action-send-mail@v3` usa Node.js 20 (GitHub esta a deprecar)
- API token e SMTP password foram expostos na conversa - **rotacionar**
