# PetCare Micro-SaaS

> Saber exatamente quem deu cada medicamento ao seu pet e permitir que qualquer pessoa que o encontre te avise instantaneamente através de um QR Code único.

## 1. Visão geral

Aplicação Flutter para Android e Web que ajuda donos de animais de estimação a gerir medicações, cuidadores, QR Codes de identificação e notificações. O objetivo central é rastrear **quem administrou cada dose** de medicação e permitir que terceiros avisem o dono se encontrarem o pet perdido, sem expor dados privados.

## 2. Stack técnica

| Camada | Tecnologia |
|--------|------------|
| Mobile / Web | Flutter 3.47.1 + Dart 3.13.1 |
| Estado | flutter_riverpod |
| Routing | go_router |
| Modelos | freezed + json_serializable |
| Backend | Supabase (Auth, Postgres, Storage, Edge Functions, Realtime, Cron) |
| Push / Analytics | Firebase Core, Cloud Messaging, Analytics, Crashlytics |
| QR | qr_flutter, mobile_scanner |
| Notificações locais | flutter_local_notifications |
| Local storage | shared_preferences |
| Build web | wrangler (Cloudflare Pages) |
| CI/CD | GitHub Actions |

## 3. Arquitetura

```
lib/
├── app.dart                  # MaterialApp + ProviderScope
├── main.dart                 # Inicialização Supabase, Firebase, Crashlytics
├── config/
│   ├── constants.dart        # Chaves públicas, limites Free/Premium
│   ├── routes.dart           # GoRouter + redirect auth
│   └── theme.dart            # Tema verde pet-friendly
├── core/
│   ├── models/               # Modelos Freezed
│   ├── services/             # Supabase, FCM, Notificações, Analytics, Deep Links
│   └── utils/                # Validators, formatters, extensions
└── modules/
    ├── auth/                 # Login, onboarding, perfil
    ├── pets/                 # CRUD de pets
    ├── medications/          # Medicações, doses de hoje, histórico
    ├── qr_code/              # Geração, partilha, scan e página pública
    ├── caregivers/           # Convites, dashboard, permissões
    ├── notifications/        # Log de notificações
    └── profile/              # Subscrição / paywall
```

## 4. Módulos e funcionalidades

| Módulo | O que faz |
|--------|-----------|
| 1 — Auth | Magic link, onboarding, perfil |
| 2 — Pets | Criar, editar, listar, foto no Storage |
| 3 — Medicação | Tipos diário/semanal/intervalo/PRN, doses, histórico, quem deu a dose |
| 4 — QR Code | QR único por pet, partilha, scan, página pública sem leak de dados |
| 5 — Cuidadores | Convite por token, dashboard, marcação de doses, sem edição |
| 6 — Notificações | Locais para doses pendentes, push para encontro e doses perdidas |
| 7 — Monetização | Trial 14 dias, paywall Free vs Premium 1,99€/mês |
| 8 — Fundação | Analytics, Crashlytics, tema, empty states, validadores |

## 5. Supabase

### 5.1 Tabelas (RLS ativo em todas)

- `profiles`
- `pets`
- `medications`
- `dose_logs`
- `caregivers`
- `pet_found_messages`
- `subscriptions`
- `notification_log`
- `user_devices`

### 5.2 Funções do banco

- `handle_new_user()` — cria perfil no primeiro registo.
- `mark_dose_given(p_dose_id, p_user_id, ...)` — marca uma dose como dada.
- `check_missed_doses()` — passa doses pendentes com >2h para `missed`.
- `get_public_pet(p_uuid)` — lookup público por QR Code.
- `accept_caregiver_invite(p_token)` — aceita convite de cuidador.

### 5.3 Storage

- Bucket `pet_photos`: fotos públicas dos pets.
- Políticas: dono pode fazer upload; qualquer um pode ler.

### 5.4 Edge Functions

- `notify-pet-found` — recebe mensagem de quem encontrou o pet, insere registo e notificação.
- `notify-dose-missed` — chamada pelo cron para verificar doses perdidas.

Ambas usam `SUPABASE_URL` e `SUPABASE_SERVICE_ROLE_KEY` fornecidos automaticamente pelo runtime, não precisam de secrets manuais.

### 5.5 Cron

Agendado em `supabase/migrations/0002_cron_dose_missed.sql`:

```sql
select cron.schedule('notify-dose-missed', '*/15 * * * *', ...);
```

Executa `notify-dose-missed` a cada 15 minutos.

### 5.6 Migrações

| Ficheiro | Descrição |
|----------|-----------|
| `0001_init.sql` | Tabelas, RLS, funções, Storage |
| `0002_cron_dose_missed.sql` | Cron de doses perdidas |
| `0003_caregiver_pets_rls.sql` | Permite cuidadores verem pets atribuídos |

Deploy via CI/CD ou Supabase CLI:

```bash
supabase db push
supabase functions deploy
```

## 6. Firebase

### Android

- Ficheiro `android/app/google-services.json` (não commitado).
- `Firebase.initializeApp()` no arranque.

### Web e Android

- `lib/firebase_options.dart` gerado com as configurações Android e Web.
- `lib/main.dart` chama `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.
- Web: app `PetCare Web` (appId `1:401594264567:web:150c29e4949b1d52701cf2`).
- Android: `google-services.json` em `android/app/` (não commitado).

## 7. Autenticação

- **Magic link** via Supabase Auth.
- `emailRedirectTo` configurado para os ambientes:
  - `http://127.0.0.1:8080/**`
  - `http://localhost:8080/**`
  - `https://*.lhr.life/**`
  - `https://petsaas.pages.dev/**`

## 8. Build e desenvolvimento

### Dependências

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Android

```bash
flutter build apk --release
flutter install
```

### Web

```bash
flutter build web --release
```

Servir localmente:

```bash
cd build/web
python -m http.server 8080
```

O ficheiro `web/_redirects` garante SPA fallback para `/p/<uuid>` e serve as páginas estáticas `/privacy` e `/terms`.

A app Web agora usa **path URL strategy** (`/p/<uuid>` em vez de `/#/p/<uuid>`), graças a `usePathUrlStrategy()`.

## 9. Testes e QA

### Ritual de screenshots

A cada módulo concluído, executar `tool/screenshot.ps1` num emulador/dispositivo com ADB:

```powershell
tool\screenshot.ps1
```

Guarda em `screenshots/`. Pasta gitignored.

### Checklist de verificação

- [ ] RLS ativo nas 9 tabelas
- [ ] Storage `pet_photos` acessível
- [ ] Edge Functions `notify-pet-found` e `notify-dose-missed` ativas
- [ ] Notificações locais disparam no Android
- [ ] QR Code gera, partilha e abre página pública
- [ ] Página pública carrega em <3s
- [ ] Paywall bloqueia 2º pet, medicação extra e cuidador extra no Free
- [ ] Trial 14 dias inicia com a primeira medicação
- [ ] Cuidador vê pets, medicações e pode marcar doses, mas não edita nada
- [ ] Dose `pending` passa a `missed` após 2h
- [ ] GitHub Actions faz deploy automático de migrations e Edge Functions
- [ ] Screenshots de todas as telas principais

### Verificação técnica em andamento

- APK release compilado com sucesso: `build/app/outputs/flutter-apk/app-release.apk`.
- End-to-end API realizado com sucesso: criação de dose, marcação, lookup público e notificação de encontro.
- Emulador não arranca neste ambiente por falta de aceleração de virtualização; testes de UI precisam de dispositivo físico.

## 10. Deploy

### Android

1. Gerar release: `flutter build apk --release`
2. Testar APK no celular real.
3. As páginas `/privacy` e `/terms` estão em `web/privacy.html` e `web/terms.html`; fazem deploy com a app web.
4. Submeter para Google Play Console (exige Termos de Uso e Política de Privacidade com URL pública).

### Web

1. `flutter build web --release`
2. Preencher `account_id` no `wrangler.toml`.
3. Correr `npx wrangler pages deploy build/web --project-name petsaas`.
4. Ou usar o GitHub Actions `.github/workflows/cloudflare-deploy.yml` com os secrets:
   - `CLOUDFLARE_ACCOUNT_ID`
   - `CLOUDFLARE_API_TOKEN`
   - `GITHUB_TOKEN`
5. Configurar domínio definitivo para que os QR Codes apontem para a URL correta.

### CI/CD

`.github/workflows/supabase-deploy.yml` faz deploy automático das migrations e Edge Functions em push para `main`.

Secrets do GitHub:
- `SUPABASE_ACCESS_TOKEN`
- `SUPABASE_PROJECT_REF`
- `CLOUDFLARE_ACCOUNT_ID`
- `CLOUDFLARE_API_TOKEN`

## 11. Configuração do ambiente

### Variáveis do Windows

```powershell
$env:FLUTTER_HOME = "C:\flutter"
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$env:ANDROID_SDK_ROOT = "$env:LOCALAPPDATA\Android\Sdk"
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
```

Adicionar ao `PATH`:
- `C:\flutter\bin`
- `%LOCALAPPDATA%\Android\Sdk\platform-tools`
- `%LOCALAPPDATA%\Android\Sdk\emulator`
- `%LOCALAPPDATA%\Android\Sdk\cmdline-tools\latest\bin`

## 12. Limitações conhecidas

- Emulador Android não testado por falta de HAXM/Hyper-V; AVD AOSP `PetCare_API_34_AOSP` criado e arranca, mas o host não tem recursos para correr a UI de forma fluída.
- ~~Configuração web do Firebase está hardcoded em `lib/main.dart`; idealmente substituir por `firebase_options.dart` gerado via `flutterfire configure`.~~ ✅ Resolvido.
- Cloudflare Pages configurado, mas **deploy depende do `account_id` e `CLOUDFLARE_API_TOKEN`**.
- Notificações locais e paywall só testáveis em dispositivo real.
- ~~Termos de Uso e Política de Privacidade ainda não criados (obrigatório para Play Store).~~ ✅ Resolvido em `web/privacy.html` e `web/terms.html`.

## 13. Próximos passos

1. ~~Gerar Termos de Uso e Política de Privacidade.~~ ✅
2. ~~Criar páginas estáticas `/privacy` e `/terms` no web.~~ ✅
3. Configurar `account_id` e `CLOUDFLARE_API_TOKEN`; fazer deploy web.
4. Testar em dispositivo físico via `flutter run`.
5. Capturar screenshots de cada módulo.
6. Criar keystore de produção e gerar `.aab`.
7. Submeter APK para Google Play Console.
