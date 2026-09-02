---
name: saas-jwt-audit
description: >-
  Audita a implementacao JWT do PetCare (Clerk -> Supabase third-party auth).
  Verifica claims do token, expiracao, algoritmo de assinatura, validacao
  no Supabase, e se policies RLS usam o claim sub corretamente. Use ao
  revisar autenticacao ou quando alterar configuracao Clerk/Supabase.
  Keywords: jwt, clerk, supabase, auth, token, sub claim, rls
  Do not use para OAuth de terceiros - PetCare usa Clerk apenas.
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
---

# SaaS JWT Audit - PetCare (Clerk + Supabase)

> Skill adaptada do projeto Anthropic-Cybersecurity-Skills (mahipal).
> Modo apenas leitura - NAO modifica codigo de producao.

## Quando usar

- Ao revisar configuracao Clerk/Supabase
- Quando alterar JWT templates no Clerk
- Ao mudar policies RLS que usam `auth.jwt()->>'sub'`
- Quando adicionar novas Edge Functions que validam JWT

## Stack do PetCare

- **Auth provider**: Clerk (clerk_flutter: ^0.0.18-beta)
- **Publishable key**: `pk_test_Y2xpbWJpbmctYnVycm8tNDkxMC5jbGVyay5hY2NvdW50cy5kZXYk`
- **Frontend API**: `https://climbing-burro-4910.clerk.accounts.dev`
- **Supabase**: Third-party auth com Clerk JWT
- **Claim usado**: `sub` (Clerk user ID, formato: `user_xxx`)
- **RLS**: Policies usam `auth.jwt()->>'sub'`

## Workflow (MODO LEITURA)

### Step 1: Verificar configuracao Clerk no Flutter

```bash
# Ler constants.dart
grep -r "clerk" lib/config/constants.dart
grep -r "ClerkPublishable" lib/config/constants.dart

# Verificar inicializacao no main.dart
grep -r "Clerk" lib/main.dart
grep -r "clerk" lib/main.dart

# Verificar se ha tokens JWT em shared_preferences
grep -r "shared_preferences" lib/ | grep -i "token\|jwt\|session"
```

**Risco PetCare**: NAO armazenar JWT em shared_preferences sem criptografia.
Usar flutter_secure_storage se necessario.

### Step 2: Verificar JWT template no Clerk

O Clerk deve ter um JWT template configurado com:
- `sub`: user ID
- `iss`: issuer
- `aud`: supabase project URL
- `exp`: expiracao (recomendado: 60s)

Verificar em: Clerk Dashboard > JWT Templates > Supabase

### Step 3: Verificar policies RLS que usam JWT

```bash
# Todas as policies que usam auth.jwt()
grep -r "auth.jwt" supabase/migrations/
grep -r "->>'sub'" supabase/migrations/

# Verificar se NAO usam auth.uid() (Supabase Auth nativo)
grep -r "auth.uid" supabase/migrations/
```

**Risco PetCare**: Se alguma policy usa `auth.uid()`, esta ERRADA para Clerk.
Deve usar `auth.jwt()->>'sub'`.

### Step 4: Verificar validacao JWT em Edge Functions

```bash
# Edge Functions que validam JWT
grep -r "jwt" supabase/functions/
grep -r "Authorization" supabase/functions/
grep -r "Bearer" supabase/functions/

# Verificar se delete-user-account valida jwtSub
grep -r "jwtSub" supabase/functions/delete-user-account/
grep -r "sub" supabase/functions/delete-user-account/
```

### Step 5: Verificar se ha JWT em logs

```bash
# NAO deve haver logs de tokens
grep -r "console.log" supabase/functions/ | grep -i "token\|jwt\|auth"
grep -r "print" lib/ | grep -i "token\|jwt\|session"
```

### Step 6: Verificar algoritmo de assinatura

O Clerk usa RS256 (RSA + SHA-256). Verificar:
- Nao usar `alg: none`
- Nao usar HS256 com chave fraca
- Supabase valida com JWKS do Clerk

### Step 7: Verificar expiracao de tokens

```bash
# Verificar se ha refresh de token
grep -r "refresh" lib/ | grep -i "token\|clerk\|session"
grep -r "session" lib/modules/auth/
```

## Output esperado

```
## Relatorio JWT Audit - PetCare

| Risco | Status | Severidade | Detalhes |
|-------|--------|------------|----------|
| Config Clerk | PASS/FAIL | Alto | ... |
| JWT template | PASS/FAIL | Alto | ... |
| RLS com sub | PASS/FAIL | Critico | ... |
| Validacao EF | PASS/FAIL | Alto | ... |
| Logs de JWT | PASS/FAIL | Alto | ... |
| Algoritmo | PASS/FAIL | Medio | RS256 |
| Expiracao | PASS/FAIL | Medio | ... |
```

## Creditos

Skill original: `testing-jwt-token-security` por mahipal.
Repositorio: https://github.com/mukul975/Anthropic-Cybersecurity-Skills
Licenca: Apache-2.0
