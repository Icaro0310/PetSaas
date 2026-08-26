import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../core/services/supabase_service.dart';
import '../../providers/app_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final profile = ref.watch(currentUserProfileProvider).valueOrNull;
    final sub = ref.watch(subscriptionProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
              child: Text(
                (profile?.fullName?.isNotEmpty ?? false)
                    ? profile!.fullName!.substring(0, 1).toUpperCase()
                    : '?',
                style: const TextStyle(fontSize: 36, color: AppTheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              profile?.fullName ?? 'Sem nome',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          Center(
            child: Text(
              SupabaseService.currentUser?.email ?? '',
              style: const TextStyle(color: AppTheme.textMuted),
            ),
          ),
          if (profile?.phone != null) ...[
            const SizedBox(height: 4),
            Center(
              child: Text(profile!.phone!,
                  style: const TextStyle(color: AppTheme.textMuted)),
            ),
          ],
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.star, color: AppTheme.accent),
              title: const Text('Plano'),
              subtitle: Text(
                sub == null
                    ? 'Free'
                    : (sub.hasPremiumAccess
                        ? 'Premium (${sub.status.name})'
                        : 'Free (expirado)'),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.subscription),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.today, color: AppTheme.primary),
              title: const Text('Doses de hoje'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.today),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_none,
                  color: AppTheme.secondary),
              title: const Text('Notificacoes'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.notifications),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              await SupabaseService.signOut();
              if (context.mounted) context.go(AppRoutes.login);
            },
            icon: const Icon(Icons.logout, color: AppTheme.danger),
            label: const Text('Sair',
                style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }
}
