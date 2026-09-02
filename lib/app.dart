import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Sincroniza o estado de auth do Clerk com SupabaseService.
class ClerkAuthSync extends StatefulWidget {
  const ClerkAuthSync({super.key, required this.child});

  final Widget child;

  @override
  State<ClerkAuthSync> createState() => _ClerkAuthSyncState();
}

class _ClerkAuthSyncState extends State<ClerkAuthSync> {
  @override
  Widget build(BuildContext context) {
    final authState = ClerkAuth.of(context);
    final user = authState.user;
    if (user != null) {
      SupabaseService.authData = ClerkAuthData(
        userId: user.id,
        email: user.email,
      );
    } else {
      SupabaseService.authData = null;
    }
    return widget.child;
  }
}
