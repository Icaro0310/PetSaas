# PostHog

Analytics de produto e session replay.

## Configuracao

| Campo | Valor |
|-------|-------|
| Project token | `phc_yUpratCpKeH3Nqgd7bmKmBZBhXa5d7D4WVwXUBiiqQYx` |
| Project ID | `264269` |
| Host | `https://eu.i.posthog.com` |
| Region | EU |

## Ficheiros relacionados

| Ficheiro | Descricao |
|----------|-----------|
| `lib/main.dart` | `Posthog().setup(config)` dentro do `appRunner` do Sentry |
| `pubspec.yaml` | `posthog_flutter: ^5.39.0` |

## Seguranca

- O **project token** e publico e seguro no cliente
- A **personal API key** (`phx_...`) NUNCA deve ir no cliente Flutter
- Inicializado dentro do `appRunner` do Sentry para que erros sejam capturados por ambos
