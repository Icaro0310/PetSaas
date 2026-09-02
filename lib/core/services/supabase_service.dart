import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/constants.dart';

/// Estado de autenticacao mantido pelo Clerk e sincronizado via
/// [ClerkAuthSync] no top-level do widget tree.
class ClerkAuthData {
  final String userId;
  final String? email;

  /// Funcao que retorna o JWT do Clerk para passar ao Supabase.
  final Future<String?> Function()? tokenProvider;

  ClerkAuthData({
    required this.userId,
    this.email,
    this.tokenProvider,
  });
}

/// Encapsula o acesso ao Supabase.
///
/// Autenticacao e gerida pelo Clerk. O Supabase e usado apenas para
/// base de dados, storage e RLS. O user ID do Clerk e usado como
/// identificador do utilizador em todas as tabelas.
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  /// Estado atual do Clerk (atualizado por ClerkAuthSync).
  static ClerkAuthData? authData;

  /// Retorna o user ID do Clerk (string, ex: user_abc123).
  static String? get currentUserId => authData?.userId;

  /// Retorna o email do utilizador atual (Clerk).
  static String? get currentUserEmail => authData?.email;

  static bool get isAuthenticated => currentUserId != null;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      publishableKey: AppConstants.supabaseAnonKey,
      debug: false,
    );
  }

  /// Sincroniza o profile do utilizador Clerk na tabela profiles.
  /// Chamado quando o utilizador faz login.
  static Future<void> syncProfile() async {
    final data = authData;
    if (data == null) return;
    try {
      await client.from('profiles').upsert({
        'id': data.userId,
        'email': data.email,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (_) {
      // Ignora erros de sync - a RLS pode bloquear se o JWT nao estiver
      // configurado ainda. O profile sera criado depois.
    }
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
