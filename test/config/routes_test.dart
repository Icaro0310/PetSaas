import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/config/routes.dart';

void main() {
  group('AppRoutes', () {
    test('todas as rotas publicas estao definidas', () {
      expect(AppRoutes.publicPet, '/p');
      expect(AppRoutes.join, '/join');
      expect(AppRoutes.scan, '/scan');
    });

    test('todas as rotas autenticadas estao definidas', () {
      expect(AppRoutes.login, '/login');
      expect(AppRoutes.onboarding, '/onboarding');
      expect(AppRoutes.pets, '/pets');
      expect(AppRoutes.petNew, '/pet/new');
      expect(AppRoutes.petDetail, '/pet');
      expect(AppRoutes.medications, '/medications');
      expect(AppRoutes.today, '/today');
      expect(AppRoutes.history, '/history');
      expect(AppRoutes.qr, '/qr');
      expect(AppRoutes.caregivers, '/caregivers');
      expect(AppRoutes.profile, '/profile');
      expect(AppRoutes.subscription, '/subscription');
      expect(AppRoutes.notifications, '/notifications');
    });

    test('rotas publicas usam paths curtos', () {
      // QR Code usa /p/:uuid e nao /pet/:uuid para URLs curtas
      expect(AppRoutes.publicPet.length, lessThan(5));
    });
  });
}
