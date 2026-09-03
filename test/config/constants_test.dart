import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/config/constants.dart';

void main() {
  group('AppConstants', () {
    test('supabaseUrl e uma URL valida https', () {
      expect(AppConstants.supabaseUrl, startsWith('https://'));
      expect(AppConstants.supabaseUrl, contains('.supabase.co'));
    });

    test('supabaseAnonKey nao e service role key', () {
      // Chaves publishable/anon comecam com sb_publishable__ ou eyJ
      expect(AppConstants.supabaseAnonKey, isNotEmpty);
      expect(AppConstants.supabaseAnonKey, isNot(contains('service_role')));
    });

    test('clerkPublishableKey comeca com pk_test_', () {
      expect(AppConstants.clerkPublishableKey, startsWith('pk_test_'));
    });

    test('siteUrl e https', () {
      expect(AppConstants.siteUrl, startsWith('https://'));
    });

    test('limites do plano free sao positivos', () {
      expect(AppConstants.freeMaxPets, greaterThan(0));
      expect(AppConstants.freeMaxCaregivers, greaterThan(0));
      expect(AppConstants.freeHistoryDays, greaterThan(0));
    });

    test('trialDays e 14', () {
      expect(AppConstants.trialDays, 14);
    });

    test('premiumMonthlyPriceEur e positivo', () {
      expect(AppConstants.premiumMonthlyPriceEur, greaterThan(0));
    });

    test('missedDoseThreshold e 2 horas', () {
      expect(AppConstants.missedDoseThreshold, const Duration(hours: 2));
    });

    test('publicPetBasePath e /p', () {
      expect(AppConstants.publicPetBasePath, '/p');
    });

    test('joinBasePath e /join', () {
      expect(AppConstants.joinBasePath, '/join');
    });

    test('petPhotosBucket nao e vazio', () {
      expect(AppConstants.petPhotosBucket, isNotEmpty);
    });
  });
}
