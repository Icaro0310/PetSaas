---
name: saas-idor-check
description: >-
  Verifica IDOR (Insecure Direct Object Reference) nas rotas Flutter e
  policies RLS do PetCare. Analisa rotas com :id ou :uuid (/p/:uuid,
  /join?token=), verifica se cuidadores so acessam pets autorizados, e
  se tokens de convite expiram em 7 dias. Use ao adicionar novas rotas
  com IDs ou ao alterar policies de caregivers.
  Keywords: idor, access control, rls, uuid, caregiver, invite token
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
  - DE.CM-01
mitre_attack:
  - T1190
  - T1059.007
---

# SaaS IDOR Check - PetCare (rotas com ID e RLS)

> Skill adaptada do projeto Anthropic-Cybersecurity-Skills (mahipal).
> Modo apenas leitura - NAO modifica codigo de producao.

## Quando usar

- Ao adicionar novas rotas com `:id` ou `:uuid` no GoRouter
- Ao alterar policies RLS de `caregivers` ou `pets`
- Quando revisar permissoes de cuidador
- Ao mudar logica de convite de cuidador

## Stack do PetCare

- **Router**: GoRouter (`lib/config/routes.dart`)
- **Rotas com ID**: `/p/:uuid` (publica), `/pets/:id` (auth), `/join?token=` (publica)
- **RLS**: 9 tabelas com policies baseadas em `auth.jwt()->>'sub'`
- **Caregivers**: tabela com `owner_id`, `caregiver_id`, `status`, `permissions`
- **Convites**: `invite_token` (deve expirar em 7 dias)

## Workflow (MODO LEITURA)

### Step 1: Mapear rotas com IDs

```bash
# Ler todas as rotas
cat lib/config/routes.dart

# Procurar rotas com :id ou :uuid
grep -n ":id" lib/config/routes.dart
grep -n ":uuid" lib/config/routes.dart
grep -n "pathParameters" lib/config/routes.dart
```

**Rotas a verificar**:
- `/p/:uuid` - publica, deve retornar apenas dados publicos do pet
- `/pets/:id` - auth, deve verificar ownership
- `/join?token=` - publica, deve validar token e expiracao

### Step 2: Verificar RLS em caregivers

```bash
# Ler policies de caregivers
grep -A 5 "caregivers" supabase/migrations/ | grep -i "policy\|using\|check"

# Verificar se caregiver so ve pets onde e owner OU caregiver
grep -r "caregiver_id" supabase/migrations/
grep -r "owner_id" supabase/migrations/
```

**Risco PetCare**: Um cuidador NAO deve:
- Ver outros pets do dono
- Editar dados do pet (apenas marcar doses)
- Ver dados pessoais do dono

### Step 3: Verificar expiracao de convites

```bash
# Procurar logica de expiracao
grep -r "invite_token" supabase/migrations/
grep -r "invited_at" supabase/migrations/
grep -r "expired" supabase/migrations/
grep -r "7 days" supabase/migrations/
grep -r "interval" supabase/migrations/ | grep -i "invite"
```

**Risco PetCare**: Se `invite_token` nao expira, atacante que descobre um
token antigo pode aceitar convite a qualquer momento.

### Step 4: Verificar se cuidador pode acessar dose_logs

```bash
# Policies de dose_logs
grep -A 5 "dose_logs" supabase/migrations/ | grep -i "policy"

# Verificar se caregiver pode inserir dose_logs
grep -r "INSERT" supabase/migrations/ | grep -i "dose_logs"
grep -r "WITH CHECK" supabase/migrations/ | grep -i "dose_logs"
```

### Step 5: Verificar se rota /p/:uuid expoe owner_id

```bash
# Ler get_public_pet
grep -A 20 "get_public_pet" supabase/migrations/

# Verificar colunas retornadas
grep -r "owner_id" supabase/migrations/ | grep -i "select\|return"
```

**Risco CRITICO**: `get_public_pet()` NAO deve retornar `owner_id`, `email`,
`telefone`, ou `endereco`. Apenas: name, species, breed, photo_url, description,
emergency_info, allergies, critical_meds, warnings, microchip_id, is_lost.

### Step 6: Verificar se rota /join valida token

```bash
# Ler logica de join
grep -r "join" lib/modules/caregivers/
grep -r "token" lib/modules/caregivers/

# Verificar se valida status do convite (pending vs accepted vs expired)
grep -r "status" lib/modules/caregivers/ | grep -i "invite\|token"
```

### Step 7: Verificar se rotas auth filtram por user_id

```bash
# Procurar queries que nao filtram por owner_id
grep -r ".select()" lib/ | grep -v "owner_id\|user_id"
grep -r ".from(" lib/ | grep -v "owner_id\|user_id"

# Verificar providers
grep -r "from('pets')" lib/providers/
grep -r "from('medications')" lib/providers/
grep -r "from('dose_logs')" lib/providers/
```

**Risco PetCare**: Se um provider faz `supabase.from('pets').select()` sem
`.eq('owner_id', userId)`, depende apenas de RLS. RLS deve bloquear, mas
e boa pratica filtrar tambem no cliente.

## Output esperado

```
## Relatorio IDOR - PetCare

| Rota/Recurso | IDOR? | Severidade | Detalhes |
|--------------|-------|------------|----------|
| /p/:uuid | PASS/FAIL | Critico | ... |
| /pets/:id | PASS/FAIL | Alto | ... |
| /join?token= | PASS/FAIL | Alto | ... |
| caregivers RLS | PASS/FAIL | Alto | ... |
| Convite expira | PASS/FAIL | Medio | ... |
| dose_logs RLS | PASS/FAIL | Alto | ... |
| get_public_pet | PASS/FAIL | Critico | ... |
```

## Creditos

Skill original: `exploiting-idor-vulnerabilities` por mahipal.
Repositorio: https://github.com/mukul975/Anthropic-Cybersecurity-Skills
Licenca: Apache-2.0
