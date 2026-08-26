import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/models/caregiver_model.dart';
import '../core/models/dose_log_model.dart';
import '../core/models/medication_model.dart';
import '../core/models/pet_model.dart';
import '../core/models/subscription_model.dart';
import '../core/models/user_model.dart';
import '../core/services/supabase_service.dart';
import '../core/utils/extensions.dart';

// ---------- Auth ----------

final authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService.client.auth.onAuthStateChange;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return SupabaseService.currentUser != null;
});

// ---------- Profile ----------

final currentUserProfileProvider =
    FutureProvider.autoDispose<UserModel?>((ref) async {
  final user = SupabaseService.currentUser;
  if (user == null) return null;
  ref.watch(authStateProvider);
  final data = await SupabaseService.client
      .from('profiles')
      .select()
      .eq('id', user.id)
      .maybeSingle();
  if (data == null) return null;
  return UserModel.fromJson(data);
});

// ---------- Subscription ----------

final subscriptionProvider =
    FutureProvider.autoDispose<SubscriptionModel?>((ref) async {
  final user = SupabaseService.currentUser;
  if (user == null) return null;
  ref.watch(authStateProvider);
  final data = await SupabaseService.client
      .from('subscriptions')
      .select()
      .eq('user_id', user.id)
      .maybeSingle();
  if (data == null) return null;
  return SubscriptionModel.fromJson(data);
});

final hasPremiumProvider = FutureProvider.autoDispose<bool>((ref) async {
  final sub = await ref.watch(subscriptionProvider.future);
  return sub?.hasPremiumAccess ?? false;
});

// ---------- Pets ----------

final petsProvider = StreamProvider.autoDispose<List<PetModel>>((ref) async* {
  final user = SupabaseService.currentUser;
  if (user == null) {
    yield [];
    return;
  }
  ref.watch(authStateProvider);
  yield* SupabaseService.client
      .from('pets')
      .stream(primaryKey: ['id'])
      .eq('owner_id', user.id)
      .map((rows) => rows
          .map((r) => PetModel.fromJson(_normalizePet(r)))
          .toList());
});

final selectedPetIdProvider = StateProvider<String?>((ref) => null);

final selectedPetProvider =
    Provider.autoDispose<PetModel?>((ref) {
  final id = ref.watch(selectedPetIdProvider);
  if (id == null) return null;
  final pets = ref.watch(petsProvider).valueOrNull ?? [];
  return pets.where((p) => p.id == id).firstOrNull;
});

// ---------- Medications ----------

final medicationsForPetProvider =
    StreamProvider.autoDispose.family<List<MedicationModel>, String>(
        (ref, petId) async* {
  ref.watch(authStateProvider);
  yield* SupabaseService.client
      .from('medications')
      .stream(primaryKey: ['id'])
      .eq('pet_id', petId)
      .map((rows) => rows
          .map((r) => MedicationModel.fromJson(_normalizeMedication(r)))
          .toList());
});

// ---------- Dose logs ----------

final todayDosesProvider =
    FutureProvider.autoDispose<List<DoseLogModel>>((ref) async {
  final user = SupabaseService.currentUser;
  if (user == null) return [];
  ref.watch(authStateProvider);
  final start = DateTime.now().dateOnly.toUtc();
  final end = start.add(const Duration(days: 1));
  final data = await SupabaseService.client
      .from('dose_logs')
      .select()
      .gte('scheduled_time', start.toIso8601String())
      .lt('scheduled_time', end.toIso8601String())
      .order('scheduled_time');
  return (data as List)
      .map((r) => DoseLogModel.fromJson(_normalizeDoseLog(r)))
      .toList();
});

// ---------- Caregivers ----------

final caregiversForPetProvider =
    StreamProvider.autoDispose.family<List<CaregiverModel>, String>(
        (ref, petId) async* {
  ref.watch(authStateProvider);
  yield* SupabaseService.client
      .from('caregivers')
      .stream(primaryKey: ['id'])
      .eq('pet_id', petId)
      .map((rows) => rows
          .map((r) => CaregiverModel.fromJson(_normalizeCaregiver(r)))
          .toList());
});

// ---------- Normalizers (snake_case DB -> model) ----------

Map<String, dynamic> _normalizePet(Map<String, dynamic> r) {
  return {
    ...r,
    'species': r['species'] as String?,
    'qr_code_uuid': r['qr_code_uuid'],
  };
}

Map<String, dynamic> _normalizeMedication(Map<String, dynamic> r) {
  return {
    ...r,
    'frequency_type': r['frequency_type'],
  };
}

Map<String, dynamic> _normalizeDoseLog(Map<String, dynamic> r) {
  return {
    ...r,
    'status': r['status'],
  };
}

Map<String, dynamic> _normalizeCaregiver(Map<String, dynamic> r) {
  return {
    ...r,
    'status': r['status'],
  };
}
