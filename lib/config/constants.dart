/// Configurações de ambiente do app.
///
/// As chaves abaixo são chaves PUBLICÁVEIS (publishable/anon) do Supabase,
/// projetadas para serem embutidas no cliente e protegidas por RLS.
/// A secret key NUNCA deve ir para o cliente.
class AppConstants {
  AppConstants._();

  // Supabase
  static const String supabaseUrl =
      'https://dotplnbakltelacsxvjz.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable__Pp5qzGJ2HlZPPD1NEdPSg_ZCCA9I9x';

  // Storage
  static const String petPhotosBucket = 'pet_photos';

  // Planos
  static const int freeMaxPets = 1;
  static const int freeMaxCaregivers = 1;
  static const int freeHistoryDays = 7;
  static const int trialDays = 14;
  static const double premiumMonthlyPriceEur = 1.99;

  // Doses
  static const Duration missedDoseThreshold = Duration(hours: 2);

  // Clerk
  static const String clerkPublishableKey =
      'pk_test_Y2xpbWJpbmctYnVycm8tNDkxMC5jbGVyay5hY2NvdW50cy5kZXYk';
  static const String clerkFrontendApiUrl =
      'https://climbing-burro-4910.clerk.accounts.dev';

  // Web deploy
  static const String siteUrl = 'https://moonlit-pothos-c56cd4.netlify.app/';

  // Redirect usado no magic link
  static const String webRedirectUrl = siteUrl;
  static const String mobileRedirectUrl = 'io.supabase.flutter://reset-callback/';

  // Deep link / página pública
  static const String publicPetBasePath = '/p';
  static const String joinBasePath = '/join';
}
