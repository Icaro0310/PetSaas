# Sentry

Captura de erros e performance monitoring.

## Configuracao

| Campo | Valor |
|-------|-------|
| DSN | `https://994d8d5c648219bc5ab06cdf891d8614@o4512017951948800.ingest.de.sentry.io/4512018103009360` |
| Region | EU (Alemanha) |
| Traces sample rate | 1.0 |
| Profiles sample rate | 1.0 |

## Ficheiros relacionados

| Ficheiro | Descricao |
|----------|-----------|
| `lib/main.dart` | `SentryFlutter.init()` + `SentryAssetBundle` |
| `pubspec.yaml` | `sentry_flutter: ^8.14.2` |

## Notas

- Configurado manualmente (o wizard falhou em ambiente non-interactive)
- `appRunner` envolve toda a inicializacao para capturar erros nativos
- `SentryAssetBundle` envolve o `DefaultAssetBundle` para capturar erros de assets
