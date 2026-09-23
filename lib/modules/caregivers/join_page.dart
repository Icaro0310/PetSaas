import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../core/services/clerk_web_auth.dart';
import '../../core/services/supabase_service.dart';
import '../../shared/widgets/loading_button.dart';

class JoinPage extends ConsumerStatefulWidget {
  final String? token;
  const JoinPage({super.key, this.token});

  @override
  ConsumerState<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends ConsumerState<JoinPage> {
  bool _accepting = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) SupabaseService.authChanges.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    if (kIsWeb) SupabaseService.authChanges.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (!mounted) return;
    setState(() {});
    if (SupabaseService.isAuthenticated && !_accepting) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _accept());
    }
  }

  Future<void> _accept() async {
    if (!mounted || widget.token == null || _accepting) return;
    setState(() => _accepting = true);
    try {
      await SupabaseService.client.rpc(
        'accept_invite',
        params: {'p_token': widget.token},
      );
      if (!mounted) return;
      context.go(AppRoutes.caregiverDashboard);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível aceitar o convite. Tente novamente.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _accepting = false);
    }
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

  @override
  Widget build(BuildContext context) {
    final authed = SupabaseService.isAuthenticated;

    return Scaffold(
      appBar: AppBar(title: const Text('Convite')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: widget.token == null
              ? const Center(child: Text('Link de convite inválido.'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.people_alt,
                      size: 56,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Foi convidado para cuidar de um animal.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!authed) ...[
                      const Text(
                        'Inicie sessão ou crie uma conta para aceitar o convite.',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 16),
                      if (kIsWeb) ...[
                        ElevatedButton.icon(
                          onPressed: () =>
                              _openClerk(context, ClerkWebAuth.openSignIn),
                          icon: const Icon(Icons.login),
                          label: const Text('Iniciar sessão'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () =>
                              _openClerk(context, ClerkWebAuth.openSignUp),
                          icon: const Icon(Icons.person_add_alt_1),
                          label: const Text('Criar conta grátis'),
                        ),
                      ] else ...[
                        ClerkErrorListener(
                          child: ClerkAuthBuilder(
                            signedInBuilder: (context, authState) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _accept();
                              });
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            signedOutBuilder: (context, authState) =>
                                const ClerkAuthentication(),
                          ),
                        ),
                      ],
                    ] else ...[
                      const Text(
                        'Confirme se pretende aceitar o convite para cuidar deste animal.',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),

                      const SizedBox(height: 20),
                      LoadingButton(
                        label: 'Aceitar convite',
                        onPressed: _accepting ? () async {} : _accept,
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
