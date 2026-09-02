import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes.dart';
import '../../config/theme.dart';
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

  Future<void> _accept() async {
    if (widget.token == null) return;
    setState(() => _accepting = true);
    try {
      await SupabaseService.client.rpc('accept_invite', params: {
        'p_token': widget.token,
      });
      if (!mounted) return;
      context.go(AppRoutes.caregiverDashboard);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro ao aceitar: $e')));
      }
    } finally {
      if (mounted) setState(() => _accepting = false);
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
              ? const Center(child: Text('Link de convite invalido.'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.people_alt, size: 56, color: AppTheme.primary),
                    const SizedBox(height: 16),
                    const Text('Foste convidado para cuidar de um pet!',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    if (!authed) ...[
                      const Text(
                          'Entra ou cria uma conta para aceitar o convite.',
                          style: TextStyle(color: AppTheme.textMuted)),
                      const SizedBox(height: 16),
                      ClerkErrorListener(
                        child: ClerkAuthBuilder(
                          signedInBuilder: (context, authState) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _accept();
                            });
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                          signedOutBuilder: (context, authState) {
                            return const ClerkAuthentication();
                          },
                        ),
                      ),
                    ] else ...[
                      const Text(
                          'Confirma para comecares a cuidar deste pet.',
                          style: TextStyle(color: AppTheme.textMuted)),
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
