import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/constants.dart';

/// Encapsula o acesso ao Supabase.
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;

  static Session? get currentSession => client.auth.currentSession;

  static bool get isAuthenticated => currentUser != null;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      publishableKey: AppConstants.supabaseAnonKey,
      debug: false,
    );
  }

  /// Envia magic link para o email.
  static Future<void> signInWithMagicLink(String email) async {
    await client.auth.signInWithOtp(
      email: email.trim(),
      emailRedirectTo:
          'io.supabase.flutter://reset-callback/', // fallback deep link
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Upload de foto para o bucket pet_photos. Retorna a URL publica.
  static Future<String?> uploadPetPhoto({
    required String petId,
    required String filePath,
    required String fileExt,
  }) async {
    final path = '$petId/${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    await client.storage
        .from(AppConstants.petPhotosBucket)
        .upload(path, File(filePath));
    return client.storage
        .from(AppConstants.petPhotosBucket)
        .getPublicUrl(path);
  }
}
