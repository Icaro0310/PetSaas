import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/constants.dart';

/// Estado de autenticacao mantido pelo Clerk e sincronizado via
/// [ClerkAuthSync] no top-level do widget tree.
class ClerkAuthData {
  final String userId;
  final String? email;

  /// Funcao que retorna o JWT do Clerk para passar ao Supabase.
  final Future<String?> Function()? tokenProvider;

  ClerkAuthData({required this.userId, this.email, this.tokenProvider});
}

/// Encapsula o acesso ao Supabase.
///
/// Autenticacao e gerida pelo Clerk. O Supabase e usado apenas para
/// base de dados, storage e RLS. O user ID do Clerk e usado como
/// identificador do utilizador em todas as tabelas.
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  /// Estado atual do Clerk (atualizado pelo adaptador de cada plataforma).
  static ClerkAuthData? authData;
  static final ValueNotifier<ClerkAuthData?> authChanges = ValueNotifier(null);

  static void updateAuthData(ClerkAuthData? data) {
    if (authData?.userId == data?.userId && authData?.email == data?.email) {
      return;
    }
    authData = data;
    authChanges.value = data;
    _syncRealtimeAuth();
  }

  static Timer? _realtimeTokenTimer;

  /// O JWT do Clerk expira em ~60s. O Realtime nao renova o token
  /// proactivamente e os canais .stream() morrem com "Token has expired".
  /// Este timer envia um token fresco a cada 45s (setAuth e no-op se
  /// o token ainda nao mudou).
  static void _syncRealtimeAuth() {
    _realtimeTokenTimer?.cancel();
    if (authData == null) return;
    unawaited(_pushRealtimeToken());
    _realtimeTokenTimer = Timer.periodic(
      const Duration(seconds: 45),
      (_) => unawaited(_pushRealtimeToken()),
    );
  }

  static Future<void> _pushRealtimeToken() async {
    final token = await authData?.tokenProvider?.call();
    if (token == null) return;
    try {
      await client.realtime.setAuth(token);
    } catch (_) {}
  }

  /// Retorna o user ID do Clerk (string, ex: user_abc123).
  static String? get currentUserId => authData?.userId;

  /// Retorna o email do utilizador atual (Clerk).
  static String? get currentUserEmail => authData?.email;

  static bool get isAuthenticated => currentUserId != null;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      publishableKey: AppConstants.supabaseAnonKey,
      accessToken: () async => await authData?.tokenProvider?.call(),
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
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (_) {
      // Ignora erros de sync - a RLS pode bloquear se o JWT nao estiver
      // configurado ainda. O profile sera criado depois.
    }
  }

  /// Upload de foto para o bucket pet_photos. Retorna a URL publica.
  /// Recebe bytes em vez de File: dart:io nao funciona na Web.
  /// A extensao/content-type sao detetados pelos magic bytes, porque na Web
  /// o path do ImagePicker e um blob URL sem extensao real.
  static Future<String?> uploadPetPhoto({
    required String petId,
    required Uint8List bytes,
    String fileExt = 'jpg',
  }) async {
    final (ext, mime) = _detectImageFormat(bytes) ?? (fileExt, 'image/jpeg');
    final path = '$petId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await client.storage
        .from(AppConstants.petPhotosBucket)
        .uploadBinary(path, bytes, fileOptions: FileOptions(contentType: mime));
    return client.storage.from(AppConstants.petPhotosBucket).getPublicUrl(path);
  }

  /// Identifica o formato da imagem pelos primeiros bytes.
  static (String ext, String mime)? _detectImageFormat(Uint8List bytes) {
    if (bytes.length < 4) return null;
    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return ('jpg', 'image/jpeg');
    }
    // PNG: 89 50 4E 47
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return ('png', 'image/png');
    }
    // GIF: 47 49 46 38
    if (bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x38) {
      return ('gif', 'image/gif');
    }
    // WebP: RIFF....WEBP
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return ('webp', 'image/webp');
    }
    return null;
  }
}
