---
name: saas-sql-check
description: >-
  Verifica SQL Injection em migrations Supabase e RPCs do PetCare. Analisa
  funcoes SECURITY DEFINER, raw SQL, concatenacao de strings em queries, e
  policies RLS que possam permitir bypass. Use ao revisar migrations ou
  quando criar novas RPCs em supabase/migrations/.
  Keywords: sql injection, supabase, postgresql, rls, rpc, security definer
  Do not use for IDOR em rotas Flutter - use saas-idor-check.
allowed-tools:
  - read
  - grep
  - glob
  - web_search
version: '1.0-petcare'
author: adaptado de mahipal (Anthropic-Cybersecurity-Skills)
license: Apache-2.0
nist_csf:
  - ID.RA-01
  - ID.RA-06
  - GV.OV-02
  - DE.AE-07
mitre_attack:
  - T1190
---

# SaaS SQL Check - PetCare (SQL Injection em Supabase)

> Skill adaptada do projeto Anthropic-Cybersecurity-Skills (mahipal).
> Modo apenas leitura - NAO modifica codigo de producao.

## Quando usar

- Ao revisar `supabase/migrations/*.sql`
- Quando criar novas RPCs (`CREATE FUNCTION`)
- Ao alterar policies de RLS
- Quando adicionar queries dinamicas em Edge Functions

## Stack do PetCare

- **DB**: PostgreSQL (Supabase)
- **Migrations**: `supabase/migrations/*.sql` (8 ficheiros)
- **RPCs**: `get_public_pet()`, `get_dose_history()`
- **RLS**: Ativa em todas as 9 tabelas (profiles, pets, medications, dose_logs,
  caregivers, subscriptions, user_devices, notifications_log, pet_found_messages)
- **Edge Functions**: TypeScript/Deno com `supabase.from('table').select()`

## Workflow (MODO LEITURA)

### Step 1: Identificar funcoes SECURITY DEFINER

```bash
grep -r "SECURITY DEFINER" supabase/migrations/
grep -r "SECURITY INVOKER" supabase/migrations/
```

**Risco PetCare**: `get_public_pet()` e SECURITY DEFINER - corre como owner,
ignora RLS. Verificar que NAO expoe dados sensiveis (owner_id, email).

### Step 2: Verificar concatenacao de strings em SQL

```bash
# Procurar || em SQL (concatenacao)
grep -r "||" supabase/migrations/

# Procurar format() com inputs dinamicos
grep -r "format(" supabase/migrations/

# Procurar EXECUTE com concatenacao
grep -r "EXECUTE" supabase/migrations/
grep -r "execute" supabase/migrations/
```

### Step 3: Verificar queries dinamicas em Edge Functions

```bash
# Procurar .rpc() em Edge Functions
grep -r ".rpc(" supabase/functions/

# Procurar raw SQL em Edge Functions
grep -r "sql:" supabase/functions/
grep -r ".from(" supabase/functions/
```

### Step 4: Verificar policies RLS

```bash
# Listar todas as policies
grep -r "CREATE POLICY" supabase/migrations/
grep -r "USING" supabase/migrations/
grep -r "WITH CHECK" supabase/migrations/

# Verificar se policies usam auth.jwt() corretamente
grep -r "auth.jwt" supabase/migrations/
grep -r "auth.uid" supabase/migrations/
```

**Risco PetCare**: As policies devem usar `auth.jwt()->>'sub'` (Clerk JWT sub),
NAO `auth.uid()` (que e do Supabase Auth nativo).

### Step 5: Verificar permissoes de execucao

```bash
# Quem pode executar get_public_pet?
grep -r "GRANT EXECUTE" supabase/migrations/
grep -r "REVOKE" supabase/migrations/

# Verificar se anon pode executar funcoes sensiveis
grep -r "to anon" supabase/migrations/
grep -r "to authenticated" supabase/migrations/
grep -r "to public" supabase/migrations/
```

### Step 6: Verificar input validation em RPCs

```bash
# get_public_pet recebe uuid - validar formato?
grep -r "uuid" supabase/migrations/ | grep -i "function"
grep -r "parameter" supabase/migrations/
```

## Output esperado

```
## Relatorio SQL Injection - PetCare

| Risco | Status | Severidade | Detalhes |
|-------|--------|------------|----------|
| SECURITY DEFINER | PASS/FAIL | Alto | get_public_pet expoe apenas campos publicos |
| Concatenacao SQL | PASS/FAIL | Critico | ... |
| Queries dinamicas | PASS/FAIL | Alto | ... |
| RLS policies | PASS/FAIL | Alto | Usam auth.jwt()->>'sub' |
| GRANT EXECUTE | PASS/FAIL | Medio | ... |
```

## Creditos

Skill original: `exploiting-sql-injection-vulnerabilities` por mahipal.
Repositorio: https://github.com/mukul975/Anthropic-Cybersecurity-Skills
Licenca: Apache-2.0
