import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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
              SupabaseService.currentUserEmail ?? '',
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
              await ClerkAuth.of(context).signOut();
              if (context.mounted) context.go(AppRoutes.login);
            },
            icon: const Icon(Icons.logout, color: AppTheme.danger),
            label: const Text('Sair',
                style: TextStyle(color: AppTheme.danger)),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _confirmDeleteAccount(context),
            icon: const Icon(Icons.delete_forever, color: AppTheme.danger),
            label: const Text('Excluir conta (LGPD)',
                style: TextStyle(color: AppTheme.danger)),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 24),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Diagnostico (debug only)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                // Em debug mode o beforeSend filtra eventos automaticos,
                // mas captureMessage com withScope ignora esse filtro.
                await Sentry.captureMessage(
                  'Sentry verification test from PetSaas',
                  level: SentryLevel.info,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Evento enviado. NOTA: em debug mode o beforeSend '
                          'filtra eventos automaticos. Para testar erros reais, '
                          'faça build em release mode.'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.bug_report),
              label: const Text('Testar Sentry'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir conta'),
        content: const Text(
          'Esta acao e IRREVERSIVEL. Todos os seus dados (pets, medicacoes, '
          'historico, cuidadores, notificacoes) serao permanentemente apagados. '
          'Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Excluir definitivamente'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    try {
      await SupabaseService.client.functions.invoke(
        'delete-user-account',
        body: {'user_id': userId},
      );
      if (context.mounted) {
        await ClerkAuth.of(context).signOut();
        context.go(AppRoutes.login);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir conta: $e')),
        );
      }
    }
  }
}
