---
name: saas-rate-limit
description: >-
  Verifica rate limiting e protecao contra abuso nas Edge Functions publicas
  do PetCare. Analisa notify-pet-found (endpoint publico sem auth), health,
  e clerk-webhook. Recomenda estrategias de throttling via Supabase ou
  Upstash Redis. Use antes de expor novos endpoints publicos.
  Keywords: rate limit, throttle, ddos, abuse, public endpoint, supabase
  Do not use para auth bypass - use saas-jwt-audit.
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
  - T1499
---

# SaaS Rate Limit - PetCare (Edge Functions publicas)

> Skill adaptada do projeto Anthropic-Cybersecurity-Skills (mahipal).
> Modo apenas leitura - NAO modifica codigo de producao.

## Quando usar

- Antes de expor novos endpoints publicos
- Ao revisar `notify-pet-found` (publico, sem auth)
- Quando adicionar webhooks
- Ao configurar cron jobs

## Stack do PetCare

- **Endpoints publicos (sem auth)**:
  - `notify-pet-found` - recebe mensagem de QR Code
  - `health` - status check
  - `clerk-webhook` - recebe eventos do Clerk (valida Svix signature)
- **Endpoints autenticados**:
  - `delete-user-account` - requer JWT
- **Hosting**: Supabase Edge Functions (Deno)

## Workflow (MODO LEITURA)

### Step 1: Identificar endpoints publicos

```bash
# Endpoints sem verificacao de Authorization
grep -rL "Authorization" supabase/functions/*/index.ts
grep -rL "auth" supabase/functions/*/index.ts
```

### Step 2: Verificar rate limiting em notify-pet-found

```bash
# Procurar implementacao de rate limit
grep -r "rate" supabase/functions/notify-pet-found/
grep -r "limit" supabase/functions/notify-pet-found/
grep -r "throttle" supabase/functions/notify-pet-found/
grep -r "bucket" supabase/functions/notify-pet-found/

# Verificar Zod validation (primeira barreira)
grep -r "zod" supabase/functions/notify-pet-found/
grep -r "schema" supabase/functions/notify-pet-found/
```

**Risco PetCare**: `notify-pet-found` e publico. Sem rate limit, atacante pode:
- Enviar milhares de mensagens spam
- Saturar tabela `pet_found_messages`
- Disparar notificacoes FCM em massa

### Step 3: Verificar rate limiting em health

```bash
grep -r "rate" supabase/functions/health/
```

**Risco baixo**: health retorna apenas `{"status":"ok"}` - pouco impacto.

### Step 4: Verificar validacao de webhook Svix

```bash
grep -r "svix" supabase/functions/clerk-webhook/
grep -r "signature" supabase/functions/clerk-webhook/
grep -r "whsec" supabase/functions/clerk-webhook/
```

### Step 5: Recomendar estrategias de rate limiting

Ler o codigo e recomendar uma das opcoes:

**Opcao A - Supabase RLS + contador**:
```sql
-- Tabela: rate_limit_log (user_id, endpoint, timestamp)
-- Policy: so pode inserir o proprio registro
-- Query: COUNT(*) WHERE timestamp > now() - interval '1 minute'
```

**Opcao B - Upstash Redis** (recomendado para Edge Functions):
```typescript
import { Redis } from "https://esm.sh/upstash-redis@1.20.0";
const redis = Redis.fromEnv();
const count = await redis.incr(`rl:${ip}:notify-pet-found`);
if (count > 5) return new Response("Too Many Requests", { status: 429 });
```

**Opcao C - Supabase Edge Function com KV**:
Usar `Deno KV` (experimental) para contador simples.

### Step 6: Verificar protecao contra spam de mensagens

```bash
# Verificar se ha limite de mensagens por pet
grep -r "count" supabase/functions/notify-pet-found/
grep -r "limit" supabase/functions/notify-pet-found/

# Verificar se ha validacao de tamanho de mensagem
grep -r "max" supabase/functions/notify-pet-found/
grep -r "length" supabase/functions/notify-pet-found/
```

## Output esperado

```
## Relatorio Rate Limiting - PetCare

| Endpoint | Publico? | Rate Limit? | Recomendacao |
|----------|----------|-------------|--------------|
| notify-pet-found | SIM | ??? | ... |
| health | SIM | N/A | ... |
| clerk-webhook | NAO (Svix) | N/A | ... |
| delete-user-account | NAO (JWT) | N/A | ... |
```

## Creditos

Skill original: `implementing-api-rate-limiting-and-throttling` por mahipal.
Repositorio: https://github.com/mukul975/Anthropic-Cybersecurity-Skills
Licenca: Apache-2.0
