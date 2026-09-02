---
name: saas-xss-check
description: >-
  Verifica XSS na pagina publica do QR Code do PetCare (public_pet_page.dart
  e web/). Analisa se inputs do utilizador (nome do finder, mensagem, foto)
  sao sanitizados antes de exibidos. Verifica tambem HTML em web/privacy.html
  e web/terms.html. Use ao alterar a pagina publica ou adicionar conteudo
  dinamico.
  Keywords: xss, cross-site scripting, sanitization, flutter web, public page
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
  - T1059.007
  - T1185
---

# SaaS XSS Check - PetCare (pagina publica QR Code)

> Skill adaptada do projeto Anthropic-Cybersecurity-Skills (mahipal).
> Modo apenas leitura - NAO modifica codigo de producao.

## Quando usar

- Ao alterar `lib/modules/qr_code/public_pet_page.dart`
- Ao modificar `web/privacy.html` ou `web/terms.html`
- Quando adicionar campos de input do finder (nome, mensagem, email)
- Ao mudar a forma como dados do pet sao exibidos

## Stack do PetCare

- **Pagina publica**: `lib/modules/qr_code/public_pet_page.dart`
- **Rota**: `/p/:uuid` (Flutter Web, sem auth)
- **Dados exibidos**: nome do pet, especie, raca, foto, descricao,
  emergency_info, allergies, critical_meds, warnings, microchip_id, is_lost
- **Inputs do finder**: finder_name, finder_email, finder_phone, message
- **HTML estatico**: `web/privacy.html`, `web/terms.html`

## Workflow (MODO LEITURA)

### Step 1: Verificar pagina publica do pet

```bash
# Ler public_pet_page.dart
cat lib/modules/qr_code/public_pet_page.dart

# Procurar Text() widgets que exibem dados do pet
grep -n "Text(" lib/modules/qr_code/public_pet_page.dart
grep -n "Text(" lib/modules/qr_code/public_pet_page.dart | grep -i "name\|description\|info"
```

**Risco baixo em Flutter**: Widgets `Text()` do Flutter escapam HTML automaticamente.
Risco existe apenas se usar `Html()` widget ou `WebView`.

### Step 2: Verificar se ha widgets Html ou WebView

```bash
grep -r "Html(" lib/
grep -r "WebView" lib/
grep -r "InAppWebView" lib/
grep -r "IframeElement" lib/
grep -r "HtmlElementView" lib/
```

**Risco CRITICO**: Se algum destes for encontrado, verificar sanitizacao.

### Step 3: Verificar inputs do finder (notify-pet-found)

```bash
# Verificar se finder_name e message sao sanitizados
grep -n "finder_name" lib/modules/qr_code/public_pet_page.dart
grep -n "message" lib/modules/qr_code/public_pet_page.dart
grep -n "controller" lib/modules/qr_code/public_pet_page.dart

# Verificar validacao no cliente
grep -n "maxLength" lib/modules/qr_code/public_pet_page.dart
grep -n "validator" lib/modules/qr_code/public_pet_page.dart
```

### Step 4: Verificar Zod validation na Edge Function

```bash
# Ler notify-pet-found
cat supabase/functions/notify-pet-found/index.ts

# Verificar schema Zod
grep -n "zod" supabase/functions/notify-pet-found/index.ts
grep -n "schema" supabase/functions/notify-pet-found/index.ts
grep -n "max" supabase/functions/notify-pet-found/index.ts
grep -n "min" supabase/functions/notify-pet-found/index.ts
```

**Risco PetCare**: message deve ter max 500 chars. finder_name max 100.
Se nao tiver, atacante pode enviar XSS armazenado que sera exibido ao dono.

### Step 5: Verificar HTML estatico (web/)

```bash
# Verificar se privacy.html e terms.html tem conteudo dinamico
grep -n "<script" web/privacy.html
grep -n "<script" web/terms.html
grep -n "innerHTML" web/privacy.html
grep -n "innerHTML" web/terms.html
grep -n "document.write" web/privacy.html
```

**Risco baixo**: HTML estatico sem JS nao tem XSS.

### Step 6: Verificar se dados do pet sao exibidos sem sanitizacao

```bash
# Verificar se emergency_info, allergies, critical_meds sao exibidos
grep -n "emergency_info" lib/modules/qr_code/public_pet_page.dart
grep -n "allergies" lib/modules/qr_code/public_pet_page.dart
grep -n "critical_meds" lib/modules/qr_code/public_pet_page.dart
grep -n "warnings" lib/modules/qr_code/public_pet_page.dart
```

**Cenario de risco**: Dono do pet regista `allergies: "<script>alert('xss')</script>"`.
Quando alguem escaneia o QR Code, se o campo for exibido em WebView, XSS executa.

### Step 7: Verificar CSP headers

```bash
# Verificar se ha CSP configurado no Netlify
cat web/_headers 2>/dev/null
cat netlify.toml 2>/dev/null
grep -r "Content-Security-Policy" web/
grep -r "Content-Security-Policy" netlify.toml 2>/dev/null
```

## Output esperado

```
## Relatorio XSS - PetCare

| Risco | Status | Severidade | Detalhes |
|-------|--------|------------|----------|
| Widgets Html/WebView | PASS/FAIL | Critico | ... |
| Inputs do finder | PASS/FAIL | Alto | max 500 chars message |
| Zod validation | PASS/FAIL | Alto | ... |
| HTML estatico | PASS/FAIL | Baixo | Sem JS dinamico |
| Dados do pet | PASS/FAIL | Medio | Text() escapa automaticamente |
| CSP headers | PASS/FAIL | Medio | ... |
```

## Creditos

Skill original: `testing-for-xss-vulnerabilities` por mahipal.
Repositorio: https://github.com/mukul975/Anthropic-Cybersecurity-Skills
Licenca: Apache-2.0
