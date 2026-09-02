# PetCare Micro-SaaS

> Saber exatamente quem deu cada medicamento ao meu pet e permitir que qualquer pessoa que o encontre me avise instantaneamente atraves de um QR Code unico.

## Indice

| Secao | Link |
|-------|------|
| Visao geral | [abaixo](#1-visao-geral) |
| Estrutura do projeto | [abaixo](#2-estrutura-do-projeto) |
| Integracoes | [integrations/](integrations/) |
| Stack | [abaixo](#3-stack) |
| Modulos | [abaixo](#4-modulos) |
| Build e deploy | [abaixo](#5-build-e-deploy) |
| Manter Supabase ativo | [abaixo](#6-manter-o-supabase-ativo) |

## 1. Visao geral

Aplicacao Flutter para Android e Web que ajuda donos de animais de estimacao a gerir medicacoes, cuidadores, QR Codes de identificacao e notificacoes. O objetivo central e rastrear **quem administrou cada dose** de medicacao e permitir que terceiros avisem o dono se encontrarem o pet perdido, sem expor dados privados.

## 2. Estrutura do projeto

```
PetSaas/
├── lib/                       # Codigo Flutter (Dart)
│   ├── app.dart               # ClerkAuth + MaterialApp
│   ├── main.dart              # Init: Sentry, PostHog, Supabase, Firebase
│   ├── config/                # Constants, routes, theme
│   ├── core/                  # Models, services, utils
│   ├── modules/               # auth, pets, medications, qr, caregivers, etc
│   ├── providers/             # Riverpod providers
│   └── shared/                # Widgets partilhados
├── android/                   # Projeto Android nativo
├── web/                       # Config Flutter Web + paginas estaticas
├── supabase/                  # Migrations, edge functions, config
│   ├── migrations/            # 0001-0008
│   └── functions/             # notify-pet-found, notify-dose-missed, clerk-webhook, health
├── integrations/              # Docs de cada integracao (ver abaixo)
├── scripts/                   # Scripts utilitarios
├── .github/workflows/         # CI/CD
├── pubspec.yaml               # Dependencias Flutter
└── README.md                  # Este ficheiro
```

### Integracoes (documentacao detalhada)

Cada integracao tem a sua propria pasta em [integrations/](integrations/) com configuracao, ficheiros relacionados e notas de seguranca:

| Integracao | Pasta | Resumo |
|------------|-------|--------|
| Supabase | [integrations/supabase/](integrations/supabase/) | Backend: Postgres, Storage, Edge Functions, RLS |
| Clerk | [integrations/clerk/](integrations/clerk/) | Autenticacao (substituiu Supabase Auth) |
| Sentry | [integrations/sentry/](integrations/sentry/) | Captura de erros e performance |
| PostHog | [integrations/posthog/](integrations/posthog/) | Analytics e session replay |
| Firebase | [integrations/firebase/](integrations/firebase/) | Crashlytics, FCM, Analytics |
| Netlify | [integrations/netlify/](integrations/netlify/) | Hosting do Flutter Web |
| UptimeRobot | [integrations/uptimerobot/](integrations/uptimerobot/) | Monitorizacao de uptime |
| MailerSend | [integrations/mailersend/](integrations/mailersend/) | Relatorio semanal por email |
| GitHub Actions | [integrations/github-actions/](integrations/github-actions/) | CI/CD e automatizacoes |

## 3. Stack

| Camada | Tecnologia |
|--------|------------|
| Mobile / Web | Flutter 3.47.1 + Dart 3.13.1 |
| Estado | flutter_riverpod |
| Routing | go_router |
| Modelos | freezed + json_serializable |
| Backend | Supabase (Postgres, Storage, Edge Functions, Realtime, Cron) |
| Auth | Clerk (third-party auth no Supabase) |
| Erros | Sentry Flutter |
| Analytics | PostHog + Firebase Analytics |
| Push | Firebase Cloud Messaging |
| QR | qr_flutter, mobile_scanner |
| Notificacoes locais | flutter_local_notifications |
| Build web | Netlify CLI |
| CI/CD | GitHub Actions |

## 4. Modulos

| Modulo | O que faz |
|--------|-----------|
| 1 - Auth | Login Clerk, onboarding, perfil |
| 2 - Pets | Criar, editar, listar, foto no Storage |
| 3 - Medicacao | Tipos diario/semanal/intervalo/PRN, doses, historico, quem deu a dose |
| 4 - QR Code | QR unico por pet, partilha, scan, pagina publica sem leak de dados |
| 5 - Cuidadores | Convite por token, dashboard, marcacao de doses, sem edicao |
| 6 - Notificacoes | Locais para doses pendentes, push para encontro e doses perdidas |
| 7 - Monetizacao | Trial 14 dias, paywall Free vs Premium 1,99 EUR/mes |
| 8 - Fundacao | Analytics, Crashlytics, tema, empty states, validadores |

## 5. Build e deploy

### Dependencias

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Web (producao)

```bash
flutter build web --release
cd build/web
netlify deploy --prod --dir=. --site moonlit-pothos-c56cd4 --auth <TOKEN>
```

URL de producao: `https://moonlit-pothos-c56cd4.netlify.app`

### Android

```bash
flutter build apk --release
flutter install
```

### Supabase (migrations + edge functions)

```bash
supabase db push
supabase functions deploy <nome> --no-verify-jwt
```

O CI/CD em `.github/workflows/supabase-deploy.yml` faz deploy automatico em push para `main`.

## 6. Manter o Supabase ativo

O Supabase Free pausa projetos inativos apos ~7 dias. Estrategia em 3 camadas:

1. **pg_cron interno** - ping as 11:00 e 23:00 UTC
2. **GitHub Actions** - ping a cada 6 horas + commit keepalive nos dias 1 e 15
3. **Relatorio semanal** - email aos domingos via MailerSend SMTP

Detalhes: [integrations/supabase/](integrations/supabase/) e [integrations/mailersend/](integrations/mailersend/)

## 7. Limitacoes conhecidas

- Android/iOS: testes suspensos ate haver dispositivo fisico
- Notificacoes locais e paywall so testaveis em dispositivo real
- Firebase Crashlytics so funciona em mobile (nao Web)
- O Clerk Flutter SDK e beta (0.0.18-beta) - API pode mudar

## 8. Proximos passos

1. Testar QR e pagina publica com o URL do Netlify
2. Testar em dispositivo fisico via `flutter run`
3. Criar keystore de producao e gerar `.aab`
4. Submeter APK para Google Play Console
5. Configurar dominio definitivo para QR Codes
