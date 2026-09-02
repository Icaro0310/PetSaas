# Clerk

Autenticacao do app. Substituiu o Supabase Auth em Set/2026.

## Configuracao

| Campo | Valor |
|-------|-------|
| Publishable key | `pk_test_Y2xpbWJpbmctYnVycm8tNDkxMC5jbGVyay5hY2NvdW50cy5kZXYk` |
| Frontend API URL | `https://climbing-burro-4910.clerk.accounts.dev` |
| JWKS URL | `https://climbing-burro-4910.clerk.accounts.dev/.well-known/jwks.json` |
| JWT Template | `supabase` (claims: `role`, `email`) |

## Integracao com Supabase

- **TPA Integration** criada via Management API
- ID: `b24241c8-9c8f-4950-81f0-78fe636a1bfb`
- OIDC issuer: `https://climbing-burro-4910.clerk.accounts.dev`
- RLS policies usam `auth.jwt()->>'sub'` para identificar o user

## Webhook

- Endpoint: `https://dotplnbakltelacsxvjz.supabase.co/functions/v1/clerk-webhook`
- Svix app ID: `app_3Imt2gPrCEfpioLQVf17G7mK13u`
- Svix endpoint ID: `ep_3ImxHWMmc08u8nHPQLWYg7Cfyb4`
- Eventos: `user.created`, `user.updated`, `user.deleted`

## Ficheiros relacionados

| Ficheiro | Descricao |
|----------|-----------|
| `lib/app.dart` | `ClerkAuth` + `ClerkAuthSync` (passa JWT ao Supabase) |
| `lib/modules/auth/login_page.dart` | UI de login com `ClerkAuthentication` |
| `lib/core/services/supabase_service.dart` | `ClerkAuthData` + `syncProfile()` |
| `lib/config/constants.dart` | Publishable key |
| `supabase/functions/clerk-webhook/index.ts` | Webhook handler |
| `supabase/migrations/0007_clerk_auth.sql` | Schema migration |
| `supabase/migrations/0008_jwt_rls.sql` | RLS com `auth.jwt()` |

## Seguranca

- A **secret key** (`sk_test_...`) NUNCA deve ir no cliente Flutter
- A publishable key e publica e segura no cliente
- Rotacionar a secret key periodicamente
