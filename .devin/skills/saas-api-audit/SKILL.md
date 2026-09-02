---
name: saas-api-audit
description: >-
  Audita Edge Functions do PetCare (Supabase) contra o OWASP API Security Top 10 (2023).
  Verifica BOLA/IDOR em rotas publicas, Broken Authentication no Clerk JWT,
  mass assignment em RPCs, rate limiting em notify-pet-found, e misconfiguration
  em CORS/headers. Use antes de deploy de novas Edge Functions ou quando revisar
  seguranca das APIs REST do Supabase.
  Keywords: supabase, edge functions, owasp, api security, rest, deno
  Do not use for SQL injection em migrations - use saas-sql-check.
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
mitre_attack:
  - T1190
  - T1059.007
  - T1505.003
---

# SaaS API Audit - PetCare (OWASP API Top 10)

> Skill adaptada do projeto Anthropic-Cybersecurity-Skills (mahipal).
> Modo apenas leitura - NAO modifica codigo de producao.

## Quando usar

- Antes de deploy de novas Edge Functions em `supabase/functions/`
- Ao revisar seguranca das APIs REST do Supabase
- Quando adicionar novas RPCs em `supabase/migrations/`
- Ao alterar policies de RLS

## Stack do PetCare

- **API**: Supabase Edge Functions (TypeScript/Deno)
- **Auth**: Clerk JWT -> Supabase third-party auth
- **DB**: PostgreSQL com RLS (Row Level Security)
- **Endpoints publicos**: `/functions/v1/notify-pet-found`, `/functions/v1/health`
- **Endpoints autenticados**: `/functions/v1/delete-user-account`, `/functions/v1/clerk-webhook`
- **RPCs**: `get_public_pet()`, `get_dose_history()`

## Workflow (MODO LEITURA - nao executar ataques)

### Step 1: Mapear endpoints

Ler `supabase/functions/*/index.ts` e listar todos os endpoints:

```bash
grep -r "Deno.serve" supabase/functions/
grep -r "req.method" supabase/functions/
grep -r "Authorization" supabase/functions/
```

Para cada Edge Function, identificar:
- E publica ou requer auth?
- Que tabelas le/escreve?
- Que inputs recebe?
- Tem Zod validation?

### Step 2: Testar API1 - BOLA/IDOR

Verificar se rotas com IDs filtram por `user_id`:

```bash
# Ler policies RLS
grep -r "USING" supabase/migrations/
grep -r "auth.jwt" supabase/migrations/

# Verificar se get_public_pet expoe owner_id
grep -r "owner_id" supabase/migrations/
grep -r "select.*from.*pets" supabase/migrations/
```

**Risco PetCare**: A rota `/p/:uuid` e publica. Verificar que `get_public_pet()`
NAO retorna: owner_id, email, telefone, endereco, historico de doses.

### Step 3: Testar API2 - Broken Authentication

```bash
# Verificar se delete-user-account valida jwtSub === user_id
grep -r "jwtSub" supabase/functions/delete-user-account/
grep -r "sub" supabase/functions/

# Verificar se clerk-webhook valida assinatura Svix
grep -r "svix" supabase/functions/clerk-webhook/
grep -r "whsec" supabase/functions/
```

### Step 4: Testar API3 - Mass Assignment

```bash
# Verificar se Edge Functions fazem INSERT/UPDATE seletivos
grep -r "insert" supabase/functions/
grep -r "update" supabase/functions/

# Verificar se notify-pet-found aceita campos extra (ex: role:admin)
grep -r "zod" supabase/functions/notify-pet-found/
```

### Step 5: Testar API4 - Rate Limiting

```bash
# notify-pet-found e publica - tem rate limit?
grep -r "rate" supabase/functions/notify-pet-found/
grep -r "limit" supabase/functions/notify-pet-found/
```

### Step 6: Testar API8 - Misconfiguration

```bash
# Verificar CORS headers
grep -r "Access-Control" supabase/functions/
grep -r "cors" supabase/functions/

# Verificar se ha logs de dados sensiveis
grep -r "console.log" supabase/functions/
grep -r "console.error" supabase/functions/
```

## Output esperado

```
## Relatorio de Auditoria API - PetCare

**Target**: supabase/functions/
**Data**: YYYY-MM-DD

| Risco | Status | Severidade | Detalhes |
|-------|--------|------------|----------|
| API1: BOLA | PASS/FAIL | Critico | ... |
| API2: Broken Auth | PASS/FAIL | Alto | ... |
| API3: Mass Assignment | PASS/FAIL | Alto | ... |
| API4: Rate Limiting | PASS/FAIL | Medio | ... |
| API8: Misconfig | PASS/FAIL | Medio | ... |
```

## Creditos

Skill original: `testing-api-security-with-owasp-top-10` por mahipal.
Repositorio: https://github.com/mukul975/Anthropic-Cybersecurity-Skills
Licenca: Apache-2.0
