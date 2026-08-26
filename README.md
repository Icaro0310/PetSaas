# PetCare Micro-SaaS

Saber exatamente quem deu cada medicamento ao seu pet e permitir que qualquer pessoa que o encontre te avise instantaneamente através de um QR Code único.

## Stack
- Flutter (Android + Web)
- Supabase (Auth, DB, Storage, Edge Functions)
- Firebase (Messaging, Analytics, Crashlytics)
- Riverpod + go_router + freezed

## Setup local

1. Flutter SDK instalado (stable).
2. `flutter pub get`
3. `dart run build_runner build` (gera arquivos freezed/json)
4. `flutter run` (Android) ou `flutter build web`

## Passos manuais no Supabase (OBRIGATÓRIO)

1. **Rodar a migração SQL**: abra o SQL Editor do Supabase e execute o conteúdo de
   `supabase/migrations/0001_init.sql`. Cria todas as tabelas, RLS, funções e o bucket de Storage.

2. **Bucket Storage**: a migração já cria o bucket `pet_photos` (público para leitura).
   Confirme em Storage que ele existe.

3. **Edge Functions**:
   ```
   supabase functions deploy notify-pet-found
   supabase functions deploy notify-dose-missed
   ```
   Defina as secrets:
   ```
   supabase secrets set SUPABASE_URL=https://dotplnbakltelacsxvjz.supabase.co
   supabase secrets set SUPABASE_SERVICE_ROLE_KEY=sb_secret_...
   ```

4. **Cron (doses perdidas)**: no SQL Editor, agende a cada 15 min:
   ```sql
   select cron.schedule(
     'notify-dose-missed',
     '*/15 * * * *',
     $$ select net.http_post(
       'https://dotplnbakltelacsxvjz.supabase.co/functions/v1/notify-dose-missed',
           '{}'::jsonb,
           '{"Authorization":"Bearer <ANON_KEY>"}'::jsonb
     ) $$
   );
   ```

5. **Auth**: no Supabase Auth, habilite Email (magic link / OTP).

6. **Firebase**: coloque `google-services.json` em `android/app/` (não commitado).
   Para web, rode `flutterfire configure` para gerar `firebase_options.dart`.

## Variáveis no app
As credenciais Supabase (publishable key) estão em `lib/config/constants.dart`
(são chaves públicas protegidas por RLS). A secret key NUNCA vai no app.

## Planos
- Free: 1 pet, 1 cuidador, histórico de 7 dias, sem foto na dose.
- Premium (1,99 EUR/mês): ilimitado + foto na dose + histórico completo.
- Trial: 14 dias automáticos ao criar a primeira medicação.
