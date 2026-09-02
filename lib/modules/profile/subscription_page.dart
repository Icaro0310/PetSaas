import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/formatters.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/loading_button.dart';

class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  bool _subscribing = false;

  Future<void> _subscribe() async {
    final user = SupabaseService.currentUserId;
    if (user == null) return;
    setState(() => _subscribing = true);
    try {
      // Placeholder: integração Stripe/IAP futura. Ativa direto para demo.
      await SupabaseService.client.from('subscriptions').upsert({
        'user_id': user,
        'status': 'active',
        'plan': 'premium',
        'current_period_start': DateTime.now().toIso8601String(),
        'current_period_end': DateTime.now()
            .add(const Duration(days: 30))
            .toIso8601String(),
      });
      ref.invalidate(subscriptionProvider);
      await AnalyticsService.subscriptionStarted();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Premium ativado! (demo)')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) setState(() => _subscribing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sub = ref.watch(subscriptionProvider).valueOrNull;
    final hasPremium = sub?.hasPremiumAccess ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.star, size: 64, color: AppTheme.accent),
            const SizedBox(height: 16),
            const Text('PetCare Premium',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              '${AppConstants.premiumMonthlyPriceEur.toStringAsFixed(2)} EUR / mes',
              style: const TextStyle(fontSize: 20, color: AppTheme.primary),
            ),
            const SizedBox(height: 24),
            const _Feature('Pets ilimitados (Free: 1)'),
            const _Feature('Cuidadores ilimitados (Free: 1)'),
            const _Feature('Medicacao e lembretes'),
            const _Feature('Historico completo (Free: 7 dias)'),
            const _Feature('Foto nas doses'),
            const SizedBox(height: 24),
            if (hasPremium) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: const Text('Plano ativo'),
                  subtitle: Text(sub?.status.name ?? ''),
                  trailing: sub?.currentPeriodEnd != null
                      ? Text('Ate ${Formatters.date(sub!.currentPeriodEnd)}')
                      : null,
                ),
              ),
            ] else ...[
              LoadingButton(
                label: 'Assinar Premium',
                icon: Icons.star,
                onPressed: _subscribing ? () async {} : _subscribe,
              ),
              const SizedBox(height: 12),
              const Text(
                'Pagamento via Stripe / in-app purchase (integracao futura). Demo ativa direto.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final String text;
  const _Feature(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
