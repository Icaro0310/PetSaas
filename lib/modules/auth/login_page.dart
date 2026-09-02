import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.pets, size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'PetCare',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Saiba quem deu cada remedio ao seu pet e seja avisado se o encontrarem.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 32),
                  TextButton.icon(
                    onPressed: () => context.push(AppRoutes.scan),
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Encontrei um pet - escanear QR'),
                  ),
                  const SizedBox(height: 16),
                  ClerkErrorListener(
                    child: ClerkAuthBuilder(
                      signedInBuilder: (context, authState) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          context.go(AppRoutes.pets);
                        });
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      signedOutBuilder: (context, authState) {
                        return const ClerkAuthentication();
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => launchUrl(
                      Uri.parse('${AppConstants.siteUrl}privacy.html'),
                    ),
                    child: const Text(
                      'Politica de Privacidade',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ),
                  TextButton(
                    onPressed: () => launchUrl(
                      Uri.parse('${AppConstants.siteUrl}terms.html'),
                    ),
                    child: const Text(
                      'Termos de Uso',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
