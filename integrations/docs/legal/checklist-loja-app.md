# Checklist para Publicacao na Google Play Store - PetCare

> Guia completo para submeter o PetCare a Google Play Console.
> Referencia: Google Play Developer Policy Center

## 1. PRE-REQUISITOS

### 1.1 Conta de desenvolvedor

- [ ] Criar conta Google Play Developer ($25 USD, pagamento unico)
- [ ] Verificar identidade (pessoa fisica ou empresa)
- [ ] Configurar 2FA na conta Google

### 1.2 Keystore de producao

- [ ] Gerar keystore de release:
  ```bash
  keytool -genkey -v -keystore petcare-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias petcare
  ```
- [ ] Guardar keystore em local SEGURO (backup encriptado)
- [ ] Configurar `android/app/build.gradle.kts` com signingConfigs
- [ ] NUNCA commitar a keystore no git

### 1.3 Build de release

- [ ] `flutter build appbundle --release` (gera .aab)
- [ ] Testar o .aab num dispositivo real antes de submeter
- [ ] Verificar que o app funciona sem internet (offline mode para dados cached)

## 2. DADOS E PRIVACIDADE (Data Safety Form)

### 2.1 Tipos de dados coletados

Declarar na Data Safety Form:

| Tipo de dado | Declarar | Finalidade |
|-------------|----------|------------|
| Nome | SIM | Identificacao do utilizador |
| Email | SIM | Autenticacao (Clerk) |
| Numero de telefone | SIM (opcional) | Perfil |
| Fotos (pet) | SIM | Funcionalidade do app |
| Localizacao | SIM (aproximada) | Mensagem "pet encontrado" |
| Informacoes de saude (pet) | SIM | Medicacoes, alergias |
| Identificadores do dispositivo | SIM | FCM Token, Device ID |
| Dados de uso/analytics | SIM | PostHog, Firebase Analytics |
| Dados de erro/crash | SIM | Sentry, Firebase Crashlytics |

### 2.2 Declaracoes obrigatorias

- [ ] Todos os dados sao criptografados em transito (HTTPS/TLS)
- [ ] Dados criptografados em repouso (Supabase AES-256)
- [ ] Utilizadores podem solicitar exclusao de dados (botao na app)
- [ ] Utilizadores podem exportar dados (via email legal@petcare.com)
- [ ] App NAO compartilha dados com terceiros para publicidade
- [ ] App NAO vende dados pessoais
- [ ] App NAO usa dados para publicidade personalizada
- [ ] Independe de verificacao de conformidade (nao certificado)

### 2.3 Politicas publicas

- [ ] URL da Politica de Privacidade: https://app.petcare.com/privacy.html
- [ ] URL dos Termos de Servico: https://app.petcare.com/terms.html
- [ ] Ambas acessiveis publicamente (verificado via curl HTTP 200)

## 3. CONTEUDO DA LISTAGEM

### 3.1 Store Listing

- [ ] **Nome da app**: PetCare - Gestao de Medicacao para Pets
- [ ] **Descricao curta** (80 chars max): Rastreia quem deu cada remedio ao seu pet. QR Code para pets perdidos.
- [ ] **Descricao completa** (4000 chars max): Incluir funcionalidades principais
- [ ] **Categoria**: Saude e Fitness ou Estilo de Vida
- [ ] **Classificacao de conteudo**: Todos os publicos (PEGI 3)
- [ ] **Target audience**: Adolescentes e adultos (16+)

### 3.2 Assets visuais

- [ ] **Icone da app**: 512x512px PNG (sem canal alpha)
- [ ] **Feature graphic**: 1024x500px JPG/PNG
- [ ] **Screenshots**: Minimo 2, maximo 8 (telefone)
  - Tela de login
  - Lista de pets
  - Medicacoes de hoje
  - QR Code
  - Pagina publica do pet
  - Perfil/assinatura
- [ ] **Video promocional** (opcional): YouTube URL

### 3.3 Idiomas

- [ ] Portugues (pt-PT) - idioma principal
- [ ] Ingles (en) - se disponivel

## 4. PERMISSOES DECLARADAS

### 4.1 Permissoes Android

| Permissao | Justificativa | Necessaria? |
|-----------|--------------|-------------|
| INTERNET | Comunicacao com Supabase/Clerk | SIM |
| ACCESS_NETWORK_STATE | Verificar conexao | SIM |
| CAMERA | Scan QR Code e foto do pet | SIM |
| READ_EXTERNAL_STORAGE | Acessar galeria para foto do pet | SIM (Android <13) |
| POST_NOTIFICATIONS | Notificacoes de doses | SIM (Android 13+) |
| ACCESS_FINE_LOCATION | Localizacao ao encontrar pet | OPCIONAL |
| ACCESS_COARSE_LOCATION | Localizacao aproximada | OPCIONAL |
| RECEIVE_BOOT_COMPLETED | Reagendar notificacoes apos reboot | SIM |
| SCHEDULE_EXACT_ALARM | Notificacoes exatas de doses | SIM |
| VIBRATE | Vibrar ao notificar | SIM |

### 4.2 Declaracao de permissoes sensiveis

- [ ] CAMERA: Justificar "para escanear QR Codes de pets e tirar fotos do seu pet"
- [ ] LOCATION: Justificar "para enviar a sua localizacao ao dono quando encontra um pet perdido (opcional)"
- [ ] NOTIFICATIONS: Justificar "para lembretes de medicacao do pet"

## 5. SEGURANCA E COMPLIANCE

### 5.1 Familias (Families Policy)

- [ ] App NAO e direcionado a criancas (target audience 16+)
- [ ] NAO selecionar "Designed for Families"

### 5.2 Permissoes de saude

- [ ] O PetCare NAO e um dispositivo medico nem faz diagnosticos
- [ ] Incluir disclaimer: "O PetCare nao substitui aconselhamento veterinario"
- [ ] NAO usar Medical Device API

### 5.3 Pagamentos

- [ ] Premium 1,99 EUR/mes - usar Google Play Billing (NAO Stripe direto)
- [ ] Declarar produtos de compra na app (in-app products)
- [ ] Configurar produtos no Play Console:
  - `premium_monthly` - 1,99 EUR/mes
- [ ] Integrar Google Play Billing Library (PENDENTE - atualmente sem pagamento na app)

### 5.4 Ads (publicidade)

- [ ] App NAO contem anuncios
- [ ] NAO declarar SDKs de publicidade

### 5.5 Dados de menores

- [ ] NAO recolher dados de menores de 16 anos
- [ ] Implementar verificacao de idade no registo (Clerk)

## 6. TESTES ANTES DE SUBMETER

### 6.1 Teste interno

- [ ] Criar release de teste interno no Play Console
- [ ] Testar em pelo menos 3 dispositivos diferentes
- [ ] Verificar fluxo completo: registo -> pet -> medicacao -> dose -> QR -> cuidador

### 6.2 Teste fechado

- [ ] Criar lista de testadores (20-100 utilizadores)
- [ ] Recolher feedback por 7 dias
- [ ] Corrigir bugs criticos

### 6.3 Pre-launch report

- [ ] Verificar Pre-launch Report do Google (roda em dispositivos Firebase Test Lab)
- [ ] Corrigir warnings/crashes identificados

## 7. SCHEMA DO BANCO VERIFICADO

### Campos declarados vs existentes no Supabase:

| Tabela | Campos principais | Status |
|--------|------------------|--------|
| profiles | id (text), full_name, phone, avatar_url | VERIFICADO |
| pets | id (uuid), owner_id (text), name, species, breed, photo_url, qr_code_uuid | VERIFICADO |
| medications | id (uuid), pet_id (uuid), name, dosage, frequency_type | VERIFICADO |
| dose_logs | id (uuid), medication_id (uuid), pet_id (uuid), given_by (text), status | VERIFICADO |
| caregivers | id (uuid), pet_id (uuid), owner_id (text), caregiver_id (text), status | VERIFICADO |
| subscriptions | id (uuid), user_id (text), status, plan | VERIFICADO |
| user_devices | id (uuid), user_id (text), fcm_token, platform | VERIFICADO |
| notifications_log | id (uuid), user_id (text), type, title, body | VERIFICADO |
| pet_found_messages | id (uuid), pet_id (uuid), qr_code_uuid, finder_name, message | VERIFICADO |

Todos os campos declarados na Politica de Privacidade existem no schema.

## 8. APOS A APROVACAO

- [ ] Monitorar reviews e ratings semanalmente
- [ ] Responder a reviews negativas em 48h
- [ ] Monitorar crashes via Firebase Crashlytics
- [ ] Atualizar app pelo menos 1x por ano (politica do Google)
- [ ] Renovar registro DMCA em 2029-09-02

## 9. DOCUMENTOS LEGAIS NECESSARIOS

- [ ] Termos de Servico publicados (docs/legal/termos-de-servico.txt)
- [ ] Politica de Privacidade publicada (docs/legal/politica-de-privacidade.txt)
- [ ] Registro DMCA no copyright.gov (ACAO MANUAL)
- [ ] Politica de reembolso (incluir nos Termos)
- [ ] Politica de suporte (email de contacto)

---

Documento gerado em 02 de setembro de 2026.
