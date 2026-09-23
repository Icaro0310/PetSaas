import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../core/services/clerk_web_auth.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final spacing = wide ? 28.0 : 18.0;
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(wide ? 32 : 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: SizedBox(
                    width: double.infinity,
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Expanded(
                                flex: 6,
                                child: _WelcomePanel(wide: true),
                              ),
                              SizedBox(width: spacing),
                              Expanded(
                                flex: 5,
                                child: _AccountPanel(
                                  onScan: () => context.push(AppRoutes.scan),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _WelcomePanel(wide: false),
                              SizedBox(height: spacing),
                              _AccountPanel(
                                onScan: () => context.push(AppRoutes.scan),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    final headingSize = wide ? 50.0 : 36.0;
    return Container(
      constraints: BoxConstraints(minHeight: wide ? 560 : 0),
      padding: EdgeInsets.all(wide ? 40 : 26),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.pets, color: AppTheme.primaryDark),
              ),
              const SizedBox(width: 12),
              const Text(
                'PetCare',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: wide ? 92 : 34),
          Text(
            'O cuidado do seu animal, partilhado.',
            style: TextStyle(
              color: Colors.white,
              fontSize: headingSize,
              height: 1.04,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.4,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Registe a medicação, coordene os cuidados e crie um QR Code de identificação.',
            style: TextStyle(
              color: AppTheme.onPrimaryMuted,
              fontSize: wide ? 18 : 16,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 34),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.qr_code_2, color: AppTheme.accent, size: 23),
                SizedBox(width: 10),
                Text(
                  'Medicação · cuidadores · identificação',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountPanel extends StatelessWidget {
  const _AccountPanel({required this.onScan});

  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'A sua conta',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Entre para continuar ou crie uma conta gratuita.',
            style: TextStyle(color: AppTheme.textMuted, height: 1.5),
          ),
          const SizedBox(height: 24),
          if (kIsWeb) ...[
            FilledButton.icon(
              onPressed: () => _openClerk(context, ClerkWebAuth.openSignIn),
              icon: const Icon(Icons.login),
              label: const Text('Iniciar sessão'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _openClerk(context, ClerkWebAuth.openSignUp),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Criar conta grátis'),
            ),
          ] else ...[
            ClerkErrorListener(
              child: ClerkAuthBuilder(
                signedInBuilder: (context, authState) =>
                    const Center(child: CircularProgressIndicator()),
                signedOutBuilder: (context, authState) =>
                    const ClerkAuthentication(),
              ),
            ),
          ],
          const SizedBox(height: 18),
          TextButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Encontrei um animal. Ler QR Code'),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              TextButton(
                onPressed: () =>
                    launchUrl(Uri.parse('${AppConstants.siteUrl}privacy.html')),
                child: const Text('Política de privacidade'),
              ),
              TextButton(
                onPressed: () =>
                    launchUrl(Uri.parse('${AppConstants.siteUrl}terms.html')),
                child: const Text('Termos de utilização'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openClerk(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível carregar a autenticação. Atualize a página.',
          ),
        ),
      );
    }
  }
}
