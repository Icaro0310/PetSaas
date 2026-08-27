import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/supabase_service.dart';
import '../modules/auth/login_page.dart';
import '../modules/auth/onboarding_page.dart';
import '../modules/auth/profile_setup_page.dart';
import '../modules/pets/pets_list_page.dart';
import '../modules/pets/pet_form_page.dart';
import '../modules/pets/pet_detail_page.dart';
import '../modules/medications/medications_list_page.dart';
import '../modules/medications/medication_form_page.dart';
import '../modules/medications/today_doses_page.dart';
import '../modules/medications/dose_history_page.dart';
import '../modules/qr_code/qr_code_page.dart';
import '../modules/qr_code/qr_scanner_page.dart';
import '../modules/caregivers/caregivers_list_page.dart';
import '../modules/caregivers/invite_caregiver_page.dart';
import '../modules/caregivers/caregiver_dashboard_page.dart';
import '../modules/profile/profile_page.dart';
import '../modules/profile/subscription_page.dart';
import '../modules/notifications/notifications_page.dart';
import '../modules/qr_code/public_pet_page.dart';
import '../modules/caregivers/join_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String onboarding = '/onboarding';
  static const String profileSetup = '/profile-setup';
  static const String pets = '/pets';
  static const String petNew = '/pet/new';
  static const String petDetail = '/pet';
  static const String petEdit = '/pet/edit';
  static const String medications = '/medications';
  static const String medicationNew = '/medication/new';
  static const String today = '/today';
  static const String history = '/history';
  static const String qr = '/qr';
  static const String caregivers = '/caregivers';
  static const String invite = '/invite';
  static const String caregiverDashboard = '/caregiver-dashboard';
  static const String profile = '/profile';
  static const String subscription = '/subscription';
  static const String notifications = '/notifications';
  static const String publicPet = '/p'; // rota pública curta
  static const String join = '/join';
  static const String scan = '/scan';

  static Future<bool> _hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_seen') ?? false;
  }

  static GoRouter buildRouter() {
    return GoRouter(
      initialLocation: pets,
      redirect: (context, state) async {
        final path = state.uri.path;
        final isPublic =
            path.startsWith(publicPet + '/') || path == join || path == scan;
        final authed = SupabaseService.isAuthenticated;

        if (isPublic) return null;

        if (!authed) {
          if (path == login) return null;
          return login;
        }

        // Autenticado
        if (path == login) {
          final seen = await _hasSeenOnboarding();
          return seen ? pets : onboarding;
        }
        return null;
      },
      routes: [
        GoRoute(path: login, builder: (_, __) => const LoginPage()),
        GoRoute(path: onboarding, builder: (_, __) => const OnboardingPage()),
        GoRoute(
            path: profileSetup, builder: (_, __) => const ProfileSetupPage()),
        GoRoute(path: pets, builder: (_, __) => const PetsListPage()),
        GoRoute(path: petNew, builder: (_, __) => const PetFormPage()),
        GoRoute(
          path: '$petDetail/:id',
          builder: (_, state) =>
              PetDetailPage(petId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '$petEdit/:id',
          builder: (_, state) =>
              PetFormPage(petId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '$medications/:petId',
          builder: (_, state) =>
              MedicationsListPage(petId: state.pathParameters['petId']!),
        ),
        GoRoute(
          path: '$medicationNew/:petId',
          builder: (_, state) =>
              MedicationFormPage(petId: state.pathParameters['petId']!),
        ),
        GoRoute(path: today, builder: (_, __) => const TodayDosesPage()),
        GoRoute(
          path: '$history/:petId',
          builder: (_, state) =>
              DoseHistoryPage(petId: state.pathParameters['petId']!),
        ),
        GoRoute(
          path: '$qr/:petId',
          builder: (_, state) => QrCodePage(petId: state.pathParameters['petId']!),
        ),
        GoRoute(
          path: '$caregivers/:petId',
          builder: (_, state) =>
              CaregiversListPage(petId: state.pathParameters['petId']!),
        ),
        GoRoute(
          path: '$invite/:petId',
          builder: (_, state) =>
              InviteCaregiverPage(petId: state.pathParameters['petId']!),
        ),
        GoRoute(
          path: caregiverDashboard,
          builder: (_, __) => const CaregiverDashboardPage(),
        ),
        GoRoute(path: profile, builder: (_, __) => const ProfilePage()),
        GoRoute(
            path: subscription, builder: (_, __) => const SubscriptionPage()),
        GoRoute(
          path: notifications,
          builder: (_, __) => const NotificationsPage(),
        ),
        GoRoute(
          path: '$publicPet/:uuid',
          builder: (_, state) =>
              PublicPetPage(uuid: state.pathParameters['uuid']!),
        ),
        GoRoute(
          path: join,
          builder: (_, state) =>
              JoinPage(token: state.uri.queryParameters['token']),
        ),
        GoRoute(
          path: scan,
          builder: (_, __) => const QrScannerPage(),
        ),
      ],
    );
  }
}
