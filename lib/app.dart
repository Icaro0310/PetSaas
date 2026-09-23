import 'dart:async';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/constants.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'core/services/clerk_web_auth.dart';
import 'core/services/supabase_service.dart';

class PetCareApp extends ConsumerWidget {
  const PetCareApp({super.key});

  @override
  Widget build(BuildContext context, ref) {
    if (kIsWeb) {
      return const ClerkWebAuthSync(child: _MaterialApp());
    }
    return ClerkAuth(
      config: ClerkAuthConfig(publishableKey: AppConstants.clerkPublishableKey),
      child: const ClerkAuthSync(child: _MaterialApp()),
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
      theme: AppTheme.light(fontFamily: kIsWeb ? 'DM Sans' : null),
      routerConfig: AppRoutes.buildRouter(),
    );
  }
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
  String? _syncedUserId;

  @override
  Widget build(BuildContext context) {
    final authState = ClerkAuth.of(context);
    final user = authState.user;

    if (user == null) {
      SupabaseService.updateAuthData(null);
      _syncedUserId = null;
    } else {
      SupabaseService.updateAuthData(
        ClerkAuthData(
          userId: user.id,
          email: user.email,
          tokenProvider: () async => (await authState.sessionToken()).jwt,
        ),
      );
      if (_syncedUserId != user.id) {
        _syncedUserId = user.id;
        unawaited(SupabaseService.syncProfile());
      }
    }

    return widget.child;
  }
}

class ClerkWebAuthSync extends StatefulWidget {
  const ClerkWebAuthSync({super.key, required this.child});

  final Widget child;

  @override
  State<ClerkWebAuthSync> createState() => _ClerkWebAuthSyncState();
}

class _ClerkWebAuthSyncState extends State<ClerkWebAuthSync> {
  StreamSubscription<ClerkWebUser?>? _subscription;
  String? _syncedUserId;

  @override
  void initState() {
    super.initState();
    _initializeClerkWeb();
  }

  Future<void> _initializeClerkWeb() async {
    try {
      await ClerkWebAuth.initialize();
      _applyUser(await ClerkWebAuth.currentUser());
      _subscription = ClerkWebAuth.authChanges.listen(_applyUser);
    } catch (_) {
      SupabaseService.updateAuthData(null);
    }
  }

  void _applyUser(ClerkWebUser? user) {
    if (user == null) {
      _syncedUserId = null;
      SupabaseService.updateAuthData(null);
      return;
    }

    SupabaseService.updateAuthData(
      ClerkAuthData(
        userId: user.id,
        email: user.email,
        tokenProvider: ClerkWebAuth.sessionToken,
      ),
    );
    if (_syncedUserId != user.id) {
      _syncedUserId = user.id;
      unawaited(SupabaseService.syncProfile());
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
