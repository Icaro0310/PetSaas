import 'dart:async';
import 'dart:convert';
import 'dart:io' show File;

import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';
// ignore: implementation_imports - ClerkFileCache nao e exportado pelo barrel
import 'package:clerk_flutter/src/utils/clerk_file_cache.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/constants.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'core/services/supabase_service.dart';

class PetCareApp extends ConsumerWidget {
  const PetCareApp({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ClerkAuth(
      config: ClerkAuthConfig(
        publishableKey: AppConstants.clerkPublishableKey,
        // Na web o DefaultCachingPersistor usa path_provider (sem impl web)
        // e mata o arranque da app. Usar localStorage via SharedPreferences.
        persistor: kIsWeb ? _WebPersistor() : null,
        fileCache: kIsWeb ? _WebFileCache() : null,
      ),
      child: const ClerkAuthSync(
        child: _MaterialApp(),
      ),
    );
  }
}

class _MaterialApp extends StatelessWidget {
  const _MaterialApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PetCare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: AppRoutes.buildRouter(),
    );
  }
}

/// Persistor web para o Clerk: serializa o cache numa unica entrada
/// JSON em SharedPreferences (localStorage). Equivalente ao
/// DefaultPersistor, mas sem depender de ficheiros.
class _WebPersistor implements clerk.Persistor {
  static const _prefsKey = 'clerk_sdk_cache';

  SharedPreferences? _prefs;
  final _cache = <String, dynamic>{};

  @override
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs?.getString(_prefsKey);
    if (raw != null) {
      try {
        _cache.addAll(json.decode(raw) as Map<String, dynamic>);
      } on FormatException {
        await _prefs?.remove(_prefsKey);
      }
    }
  }

  @override
  void terminate() {}

  @override
  FutureOr<T?> read<T>(String key) => _cache[key] as T?;

  @override
  FutureOr<void> write<T>(String key, T value) {
    _cache[key] = value;
    _save();
  }

  @override
  FutureOr<void> delete(String key) {
    if (_cache.remove(key) != null) _save();
  }

  void _save() {
    _prefs?.setString(_prefsKey, json.encode(_cache));
  }
}

/// File cache no-op para web: a interface [ClerkFileCache] e baseada em
/// dart:io File, que nao existe na web. Imagens do Clerk UI simplesmente
/// nao usam cache (stream vazio).
class _WebFileCache implements ClerkFileCache {
  @override
  Future<void> initialize() async {}

  @override
  void terminate() {}

  @override
  Stream<File> stream(
    Uri uri, {
    Duration ttl = ClerkFileCache.defaultTTL,
    Map<String, String>? headers,
  }) =>
      const Stream.empty();
}

/// Sincroniza o estado de auth do Clerk com SupabaseService.
/// Tambem configura o Supabase client para usar o JWT do Clerk.
class ClerkAuthSync extends StatefulWidget {
  const ClerkAuthSync({super.key, required this.child});

  final Widget child;

  @override
  State<ClerkAuthSync> createState() => _ClerkAuthSyncState();
}

class _ClerkAuthSyncState extends State<ClerkAuthSync> {
  bool _synced = false;

  @override
  Widget build(BuildContext context) {
    final authState = ClerkAuth.of(context);
    final user = authState.user;

    if (user != null) {
      SupabaseService.authData = ClerkAuthData(
        userId: user.id,
        email: user.email,
      );
      // Sincroniza profile uma vez por login
      if (!_synced) {
        _synced = true;
        _syncProfileAndToken();
      }
    } else {
      SupabaseService.authData = null;
      _synced = false;
    }

    return widget.child;
  }

  Future<void> _syncProfileAndToken() async {
    try {
      // Tenta obter o session token do Clerk e passar ao Supabase
      final authState = ClerkAuth.of(context);
      final token = await authState.sessionToken();
      if (token?.jwt != null) {
        await Supabase.instance.client.auth.setSession(token!.jwt!);
      }
    } catch (_) {
      // Ignora - o token pode nao estar disponivel imediatamente
    }
    await SupabaseService.syncProfile();
  }
}
