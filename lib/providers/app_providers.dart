import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/caregiver_model.dart';
import '../core/models/dose_log_model.dart';
import '../core/models/medication_model.dart';
import '../core/models/pet_model.dart';
import '../core/models/subscription_model.dart';
import '../core/models/user_model.dart';
import '../core/services/supabase_service.dart';
import '../core/utils/extensions.dart';

// ---------- Auth ----------

/// Provider simples que indica se ha utilizador autenticado (Clerk).
final isAuthenticatedProvider = Provider<bool>((ref) {
  return SupabaseService.isAuthenticated;
});

/// Provider que retorna o user ID do Clerk.
final currentUserIdProvider = Provider<String?>((ref) {
  return SupabaseService.currentUserId;
});

// ---------- Profile ----------

final currentUserProfileProvider =
    FutureProvider.autoDispose<UserModel?>((ref) async {
  final userId = SupabaseService.currentUserId;
  if (userId == null) return null;
  ref.watch(currentUserIdProvider);
  final data = await SupabaseService.client
      .from('profiles')
      .select()
      .eq('id', userId)
      .maybeSingle();
  if (data == null) return null;
  return UserModel.fromJson(data);
});

// ---------- Subscription ----------

final subscriptionProvider =
    FutureProvider.autoDispose<SubscriptionModel?>((ref) async {
  final userId = SupabaseService.currentUserId;
  if (userId == null) return null;
  ref.watch(currentUserIdProvider);
  final data = await SupabaseService.client
      .from('subscriptions')
      .select()
      .eq('user_id', userId)
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
  final userId = SupabaseService.currentUserId;
  if (userId == null) {
    yield [];
    return;
  }
  ref.watch(currentUserIdProvider);
  yield* SupabaseService.client
      .from('pets')
      .stream(primaryKey: ['id'])
      .eq('owner_id', userId)
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

/// Indica se o utilizador atual e DONO do pet selecionado.
/// Cuidadores veem apenas visualizacao + marcar doses.
final isOwnerOfSelectedPetProvider = FutureProvider.autoDispose<bool>((ref) async {
  final pet = ref.watch(selectedPetProvider);
  final userId = SupabaseService.currentUserId;
  if (pet == null || userId == null) return false;
  // Se o pet esta na lista de pets do dono, e dono.
  final pets = ref.watch(petsProvider).valueOrNull ?? [];
  if (pets.any((p) => p.id == pet.id)) return true;
  // Caso contrario, verifica se e cuidador ativo deste pet.
  final cg = await SupabaseService.client
      .from('caregivers')
      .select('id')
      .eq('pet_id', pet.id)
      .eq('caregiver_id', userId)
      .eq('status', 'active')
      .maybeSingle();
  return cg == null; // se nao e cuidador, assume dono (fallback)
});

// ---------- Medications ----------

final medicationsForPetProvider =
    StreamProvider.autoDispose.family<List<MedicationModel>, String>(
        (ref, petId) async* {
  ref.watch(currentUserIdProvider);
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
  final userId = SupabaseService.currentUserId;
  if (userId == null) return [];
  ref.watch(currentUserIdProvider);
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
  ref.watch(currentUserIdProvider);
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
