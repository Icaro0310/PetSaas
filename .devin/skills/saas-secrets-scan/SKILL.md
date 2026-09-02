---
name: saas-secrets-scan
description: >-
  Procura segredos hardcoded no codigo Flutter (lib/) e Edge Functions
  (supabase/functions/) do PetCare. Verifica chaves service_role do Supabase,
  FCM server keys, google-services.json, GoogleService-Info.plist, JWT
  secrets, e variaveis de ambiente. Use antes de commit ou como pre-commit hook.
  Keywords: secrets, hardcoded, service_role, fcm, google-services, env
  Do not use para SQL injection - use saas-sql-check.
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
mitre_attack:
  - T1552
  - T1552.001
---

# SaaS Secrets Scan - PetCare (detecao de segredos hardcoded)

> Skill adaptada do projeto Anthropic-Cybersecurity-Skills (mahipal).
> Modo apenas leitura - NAO modifica codigo de producao.

## Quando usar

- Antes de commit (pre-commit hook)
- Ao revisar PRs
- Quando adicionar novas dependencias
- Apos mudancas em `lib/config/constants.dart`
- Periodicamente (scan semanal)

## Stack do PetCare

- **Cliente Flutter**: `lib/` (Dart)
- **Edge Functions**: `supabase/functions/` (TypeScript/Deno)
- **Config publica**: `lib/config/constants.dart` (apenas chaves publishable)
- **Config nativa**: `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`
- **CI/CD**: `.github/workflows/`

## Padroes a procurar (MODO LEITURA)

### Step 1: Procurar chaves service_role do Supabase

```bash
grep -r "service_role" lib/
grep -r "SERVICE_ROLE" lib/
grep -r "sb_secret_" lib/
grep -r "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9" lib/  # JWT base64
grep -r "service_role" supabase/functions/
```

**Risco CRITICO**: service_role NUNCA no cliente Flutter.
Deve estar apenas em variaveis de ambiente das Edge Functions.

### Step 2: Procurar FCM server keys

```bash
grep -r "FCM_SERVER_KEY" lib/
grep -r "AAAA" lib/ | grep -i "fcm\|firebase"  # FCM keys comecam com AAAA
grep -r "server_key" lib/
grep -r "authorization.*key" lib/ | grep -i "fcm"
```

### Step 3: Procurar google-services.json e GoogleService-Info.plist

```bash
# Verificar se estao no .gitignore
grep "google-services.json" .gitignore
grep "GoogleService-Info.plist" .gitignore

# Verificar se estao commitados
grep -r "google-services.json" .gitignore
git log --all --full-history -- android/app/google-services.json
git log --all --full-history -- ios/Runner/GoogleService-Info.plist
```

### Step 4: Procurar chaves Clerk secretas

```bash
grep -r "sk_test_" lib/
grep -r "sk_live_" lib/
grep -r "sk_" lib/ | grep -i "clerk"
grep -r "CLERK_SECRET" lib/
```

**Risco**: Apenas `pk_test_` (publishable) e permitido no cliente.
`sk_test_` e `sk_live_` sao SECRETAS.

### Step 5: Procurar chaves OpenAI/Anthropic/etc

```bash
grep -r "OPENAI_API_KEY" lib/
grep -r "sk-ant-" lib/  # Anthropic
grep -r "sk-proj-" lib/  # OpenAI
grep -r "ANTHROPIC_API_KEY" lib/
```

### Step 6: Procurar strings base64 suspeitas (JWT, certificados)

```bash
# JWTs tem 3 partes separadas por .
grep -rE "eyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+" lib/
grep -rE "eyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+" supabase/functions/

# Chaves privadas PEM
grep -r "BEGIN PRIVATE KEY" lib/
grep -r "BEGIN RSA PRIVATE KEY" lib/
grep -r "BEGIN PRIVATE KEY" supabase/functions/
```

### Step 7: Procurar credenciais em .env commitados

```bash
# Verificar se .env esta no .gitignore
grep ".env" .gitignore

# Procurar ficheiros .env no repo
find . -name ".env" -not -path "./.git/*"
find . -name ".env.local" -not -path "./.git/*"
find . -name ".env.production" -not -path "./.git/*"
```

### Step 8: Verificar git history (se gitleaks disponivel)

```bash
# Se gitleaks estiver instalado
gitleaks detect --source . --verbose

# Alternativa manual
git log -p --all -S "service_role" -- lib/
git log -p --all -S "sb_secret_" -- lib/
git log -p --all -S "FCM_SERVER_KEY" -- lib/
```

### Step 9: Verificar variaveis permitidas no cliente

O `lib/config/constants.dart` DEVE conter APENAS:
- `supabaseUrl` (publico)
- `supabaseAnonKey` (publishable, prefixo `sb_publishable_`)
- `clerkPublishableKey` (publishable, prefixo `pk_test_` ou `pk_live_`)
- `clerkFrontendApiUrl` (publico)
- `siteUrl` (publico)

E NAO DEVE conter:
- `SUPABASE_SERVICE_ROLE_KEY`
- `CLERK_SECRET_KEY`
- `FCM_SERVER_KEY`
- `GOOGLE_APPLICATION_CREDENTIALS`
- Qualquer `sk_test_`, `sk_live_`, `sb_secret_`

## Output esperado

```
## Relatorio Secrets Scan - PetCare

| Tipo | Ficheiro | Linha | Severidade | Status |
|------|----------|-------|------------|--------|
| service_role | - | - | Critico | PASS (nao encontrado) |
| FCM server key | - | - | Critico | PASS |
| google-services.json | .gitignore | - | Alto | PASS (gitignored) |
| Clerk secret | - | - | Critico | PASS |
| OpenAI key | - | - | Alto | PASS |
| JWT em codigo | - | - | Alto | PASS |
| .env commitado | - | - | Alto | PASS |

Total: 0 segredos encontrados.
```

## Creditos

Skill original: `implementing-secret-scanning-with-gitleaks` por mahipal.
Repositorio: https://github.com/mukul975/Anthropic-Cybersecurity-Skills
Licenca: Apache-2.0
