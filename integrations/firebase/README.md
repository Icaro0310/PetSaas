# Firebase

Firebase Core, Crashlytics, Messaging (FCM) e Analytics.

## Configuracao

| Campo | Valor |
|-------|-------|
| Project | PetSaas (Icaro0310) |
| Platform | Android + Web |
| Crashlytics | Ativo (apenas mobile) |
| FCM | Ativo (push notifications) |
| Analytics | Ativo |

## Ficheiros relacionados

| Ficheiro | Descricao |
|----------|-----------|
| `lib/main.dart` | `Firebase.initializeApp()` + Crashlytics + FCM |
| `lib/firebase_options.dart` | Config gerada pelo FlutterFire CLI |
| `lib/core/services/fcm_service.dart` | Registo de token FCM no Supabase |
| `android/app/google-services.json` | Config Android |
| `pubspec.yaml` | `firebase_core`, `firebase_messaging`, `firebase_analytics`, `firebase_crashlytics` |

## Notas

- Inicializacao envolvida em try/catch para nao quebrar o app se Firebase falhar
- Crashlytics so funciona em mobile (nao Web)
- FCM em Web usa o service worker do browser
- `google-services.json` e seguro de commitar (nao contem chaves secretas)
