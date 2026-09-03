import 'package:flutter_test/flutter_test.dart';

import 'package:petcare/core/models/pet_model.dart';
import 'package:petcare/core/models/medication_model.dart';
import 'package:petcare/core/models/dose_log_model.dart';
import 'package:petcare/core/models/caregiver_model.dart';
import 'package:petcare/core/models/subscription_model.dart';
import 'package:petcare/core/models/user_model.dart';

void main() {
  group('PetModel', () {
    test('fromJson parseia todos os campos corretamente', () {
      final json = {
        'id': 'pet-1',
        'ownerId': 'user-1',
        'name': 'Rex',
        'species': 'dog',
        'breed': 'Labrador',
        'birthDate': '2020-01-15T00:00:00.000Z',
        'weightKg': 25.5,
        'color': 'brown',
        'isLost': false,
        'qrCodeUuid': '550e8400-e29b-41d4-a716-446655440000',
      };
      final pet = PetModel.fromJson(json);
      expect(pet.id, 'pet-1');
      expect(pet.name, 'Rex');
      expect(pet.species, PetSpecies.dog);
      expect(pet.breed, 'Labrador');
      expect(pet.weightKg, 25.5);
      expect(pet.isLost, false);
      expect(pet.qrCodeUuid, '550e8400-e29b-41d4-a716-446655440000');
    });

    test('fromJson aceita cat como species', () {
      final pet = PetModel.fromJson({
        'id': 'pet-2',
        'ownerId': 'user-1',
        'name': 'Mimi',
        'species': 'cat',
      });
      expect(pet.species, PetSpecies.cat);
    });

    test('toJson roundtrip preserva dados', () {
      final pet = PetModel(
        id: 'pet-1',
        ownerId: 'user-1',
        name: 'Rex',
        species: PetSpecies.dog,
        isLost: true,
      );
      final json = pet.toJson();
      final pet2 = PetModel.fromJson(json);
      expect(pet2.id, pet.id);
      expect(pet2.name, pet.name);
      expect(pet2.species, pet.species);
      expect(pet2.isLost, pet.isLost);
    });

    test('valores default sao aplicados', () {
      final pet = PetModel(
        id: 'p',
        ownerId: 'u',
        name: 'Test',
        species: PetSpecies.dog,
      );
      expect(pet.isLost, false);
      expect(pet.breed, isNull);
      expect(pet.photoUrl, isNull);
    });
  });

  group('MedicationModel', () {
    test('fromJson parsea frequencia daily', () {
      final med = MedicationModel.fromJson({
        'id': 'med-1',
        'petId': 'pet-1',
        'name': 'Antibiotico',
        'dosage': '1 comprimido',
        'frequencyType': 'daily',
        'frequencyValue': 1,
        'scheduleTimes': ['08:00', '20:00'],
        'startDate': '2025-01-01T00:00:00.000Z',
        'isActive': true,
      });
      expect(med.frequencyType, FrequencyType.daily);
      expect(med.scheduleTimes, ['08:00', '20:00']);
      expect(med.isActive, true);
    });

    test('fromJson parsea interval_hours', () {
      final med = MedicationModel.fromJson({
        'id': 'med-2',
        'petId': 'pet-1',
        'name': 'Antiinflamatorio',
        'dosage': '5ml',
        'frequencyType': 'interval_hours',
        'frequencyValue': 8,
        'startDate': '2025-01-01T00:00:00.000Z',
      });
      expect(med.frequencyType, FrequencyType.interval_hours);
      expect(med.frequencyValue, 8);
    });

    test('default isActive e true', () {
      final med = MedicationModel(
        id: 'm',
        petId: 'p',
        name: 'Test',
        dosage: '1',
        frequencyType: FrequencyType.as_needed,
        startDate: DateTime(2025),
      );
      expect(med.isActive, true);
      expect(med.scheduleTimes, []);
    });
  });

  group('DoseLogModel', () {
    test('status default e pending', () {
      final dose = DoseLogModel(
        id: 'd1',
        medicationId: 'm1',
        petId: 'p1',
        scheduledTime: DateTime(2025, 1, 1, 8),
      );
      expect(dose.status, DoseStatus.pending);
    });

    test('fromJson parsea status given', () {
      final dose = DoseLogModel.fromJson({
        'id': 'd1',
        'medicationId': 'm1',
        'petId': 'p1',
        'scheduledTime': '2025-01-01T08:00:00.000Z',
        'givenAt': '2025-01-01T08:05:00.000Z',
        'givenBy': 'user-1',
        'status': 'given',
      });
      expect(dose.status, DoseStatus.given);
      expect(dose.givenBy, 'user-1');
    });
  });

  group('CaregiverModel', () {
    test('status default e pending', () {
      final cg = CaregiverModel(
        id: 'cg-1',
        petId: 'pet-1',
        ownerId: 'user-1',
        caregiverEmail: 'caregiver@example.com',
      );
      expect(cg.status, CaregiverStatus.pending);
      expect(cg.permissions, ['view', 'mark_dose']);
    });

    test('fromJson parsea status active', () {
      final cg = CaregiverModel.fromJson({
        'id': 'cg-1',
        'petId': 'pet-1',
        'ownerId': 'user-1',
        'caregiverId': 'user-2',
        'caregiverEmail': 'cg@example.com',
        'status': 'active',
        'permissions': ['view', 'mark_dose', 'edit_medication'],
      });
      expect(cg.status, CaregiverStatus.active);
      expect(cg.caregiverId, 'user-2');
      expect(cg.permissions.length, 3);
    });
  });

  group('SubscriptionModel', () {
    test('hasPremiumAccess true quando active', () {
      final sub = SubscriptionModel(
        id: 's1',
        userId: 'u1',
        status: SubscriptionStatus.active,
      );
      expect(sub.hasPremiumAccess, true);
    });

    test('hasPremiumAccess true quando trialing sem end', () {
      final sub = SubscriptionModel(
        id: 's1',
        userId: 'u1',
        status: SubscriptionStatus.trialing,
      );
      expect(sub.hasPremiumAccess, true);
    });

    test('hasPremiumAccess true quando trialing com end futuro', () {
      final sub = SubscriptionModel(
        id: 's1',
        userId: 'u1',
        status: SubscriptionStatus.trialing,
        currentPeriodEnd: DateTime.now().add(const Duration(days: 10)),
      );
      expect(sub.hasPremiumAccess, true);
    });

    test('hasPremiumAccess false quando trialing expirado', () {
      final sub = SubscriptionModel(
        id: 's1',
        userId: 'u1',
        status: SubscriptionStatus.trialing,
        currentPeriodEnd: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(sub.hasPremiumAccess, false);
    });

    test('hasPremiumAccess false quando cancelled', () {
      final sub = SubscriptionModel(
        id: 's1',
        userId: 'u1',
        status: SubscriptionStatus.cancelled,
      );
      expect(sub.hasPremiumAccess, false);
    });

    test('hasPremiumAccess false quando past_due', () {
      final sub = SubscriptionModel(
        id: 's1',
        userId: 'u1',
        status: SubscriptionStatus.past_due,
      );
      expect(sub.hasPremiumAccess, false);
    });
  });

  group('UserModel', () {
    test('fromJson parsea campos', () {
      final user = UserModel.fromJson({
        'id': 'user-1',
        'fullName': 'Icaro Galvao',
        'phone': '+351912345678',
        'avatarUrl': 'https://example.com/avatar.png',
        'createdAt': '2025-01-01T00:00:00.000Z',
      });
      expect(user.id, 'user-1');
      expect(user.fullName, 'Icaro Galvao');
      expect(user.phone, '+351912345678');
    });

    test('campos opcionais aceitam null', () {
      final user = UserModel(id: 'u1');
      expect(user.fullName, isNull);
      expect(user.phone, isNull);
      expect(user.avatarUrl, isNull);
    });
  });
}
