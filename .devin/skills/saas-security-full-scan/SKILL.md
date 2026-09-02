---
name: saas-security-full-scan
description: >-
  Executa uma auditoria completa de seguranca do PetCare SaaS, invocando
  todas as skills saas-* em sequencia. Cobertura: OWASP API Top 10 em
  Edge Functions, SQL Injection em migrations/RPCs, JWT Clerk-Supabase,
  rate limiting em endpoints publicos, secrets scanning no cliente Flutter,
  XSS na pagina publica do QR Code, e IDOR em rotas com IDs. Use antes de
  deploy para producao ou como auditoria periodica.
  Keywords: full scan, audit, security, owasp, supabase, flutter, clerk
  Do not use para auditoria individual - invoque a skill especifica.
allowed-tools:
  - read
  - grep
  - glob
  - web_search
version: '1.0-petcare'
author: adaptado de mahipal (Anthropic-Cybersecurity-Skills)
license: Apache-2.0
nist_csf:
  - PR.PS-01
  - ID.RA-01
  - PR.DS-10
  - DE.CM-01
  - GV.OV-02
mitre_attack:
  - T1190
  - T1059.007
  - T1552
  - T1499
---

# SaaS Security Full Scan - PetCare (auditoria completa)

> Skill mae que orquestra todas as skills saas-* do PetCare.
> Modo apenas leitura - NAO modifica codigo de producao.

## Quando usar

- Antes de deploy para producao
- Como auditoria periodica (mensal)
- Apos mudancas significativas no codigo
- Antes de submeter a Google Play Store
- Quando onboarding novo desenvolvedor

## Skills executadas (em sequencia)

| # | Skill | Foco | Severidade max |
|---|-------|------|----------------|
| 1 | saas-secrets-scan | Segredos hardcoded no cliente | Critico |
| 2 | saas-jwt-audit | Auth Clerk -> Supabase JWT | Critico |
| 3 | saas-idor-check | IDOR em rotas e RLS | Critico |
| 4 | saas-sql-check | SQL Injection em migrations | Critico |
| 5 | saas-api-audit | OWASP API Top 10 em Edge Functions | Alto |
| 6 | saas-rate-limit | Rate limiting em endpoints publicos | Medio |
| 7 | saas-xss-check | XSS na pagina publica QR | Alto |

## Workflow (MODO LEITURA)

### Fase 1: Preparacao

1. Confirmar que estamos no diretorio raiz do PetCare
2. Verificar que `lib/`, `supabase/`, `web/` existem
3. Anotar data e commit atual: `git rev-parse HEAD`

### Fase 2: Executar cada skill em sequencia

Para cada skill, executar o workflow documentado no respetivo SKILL.md:

#### 2.1 - saas-secrets-scan (PRIMEIRO - mais critico)

Verificar se ha segredos hardcoded antes de qualquer outra coisa.
Se encontrar service_role ou FCM_SERVER_KEY no cliente, **PARAR e reportar
IMEDIATAMENTO** - nao continuar o scan.

#### 2.2 - saas-jwt-audit

Verificar configuracao Clerk/Supabase, JWT templates, policies RLS com
`auth.jwt()->>'sub'`, validacao em Edge Functions.

#### 2.3 - saas-idor-check

Verificar rotas com :id/:uuid, RLS em caregivers, expiracao de convites,
get_public_pet() nao expoe owner_id.

#### 2.4 - saas-sql-check

Verificar SECURITY DEFINER, concatenacao SQL, queries dinamicas, GRANT
EXECUTE em funcoes publicas.

#### 2.5 - saas-api-audit

Verificar OWASP API Top 10 em Edge Functions: BOLA, Broken Auth, Mass
Assignment, Rate Limiting, Misconfiguration.

#### 2.6 - saas-rate-limit

Verificar rate limiting em notify-pet-found (publico), validar Zod,
recomendar Upstash Redis se necessario.

#### 2.7 - saas-xss-check

Verificar pagina publica do QR Code, inputs do finder, widgets Html/WebView,
CSP headers.

### Fase 3: Relatorio consolidado

```
====================================================
  AUDITORIA COMPLETA DE SEGURANCA - PetCare
  Data: YYYY-MM-DD HH:MM
  Commit: <sha>
  Duracao: ~X minutos
====================================================

RESUMO EXECUTIVO:

| Skill | Findings | Critico | Alto | Medio | Baixo |
|-------|----------|---------|------|-------|-------|
| saas-secrets-scan | X | X | X | X | X |
| saas-jwt-audit | X | X | X | X | X |
| saas-idor-check | X | X | X | X | X |
| saas-sql-check | X | X | X | X | X |
| saas-api-audit | X | X | X | X | X |
| saas-rate-limit | X | X | X | X | X |
| saas-xss-check | X | X | X | X | X |
| TOTAL | X | X | X | X | X |

FINDINGS CRITICOS (bloqueiam deploy):
1. ...
2. ...

FINDINGS ALTOS (devem ser corrigidos antes de release):
1. ...
2. ...

FINDINGS MEDIOS (planejar correcao):
1. ...

FINDINGS BAIXOS (backlog):
1. ...

RECOMENDACOES:
1. ...
2. ...

PROXIMOS PASSOS:
[ ] Corrigir findings criticos
[ ] Corrigir findings altos
[ ] Planejar findings medios
[ ] Backlog findings baixos
[ ] Re-executar saas-security-full-scan apos correcoes
```

## Constraints

- **NAO modificar codigo** - todas as skills sao read-only
- **NAO commitar** - apenas reportar findings
- **NAO executar ataques reais** - apenas analise estatica
- Se encontrar finding CRITICO, **PARAR e reportar imediatamente**
- Manter licencas e creditos das skills originais

## Creditos

Skill mae adaptada do projeto Anthropic-Cybersecurity-Skills (mahipal).
Repositorio: https://github.com/mukul975/Anthropic-Cybersecurity-Skills
Licenca: Apache-2.0

Skills individuais:
- saas-api-audit <- testing-api-security-with-owasp-top-10
- saas-sql-check <- exploiting-sql-injection-vulnerabilities
- saas-jwt-audit <- testing-jwt-token-security
- saas-rate-limit <- implementing-api-rate-limiting-and-throttling
- saas-secrets-scan <- implementing-secret-scanning-with-gitleaks
- saas-xss-check <- testing-for-xss-vulnerabilities
- saas-idor-check <- exploiting-idor-vulnerabilities
