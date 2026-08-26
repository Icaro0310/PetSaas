import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/validators.dart';
import '../../shared/widgets/loading_button.dart';

class JoinPage extends ConsumerStatefulWidget {
  final String? token;
  const JoinPage({super.key, this.token});

  @override
  ConsumerState<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends ConsumerState<JoinPage> {
  final _email = TextEditingController();
  final _name = TextEditingController();
  bool _linkSent = false;
  bool _accepting = false;

  Future<void> _sendLink() async {
    if (Validators.email(_email.text) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email invalido.')),
      );
      return;
    }
    try {
      await SupabaseService.signInWithMagicLink(_email.text);
      setState(() => _linkSent = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }

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
  void dispose() {
    _email.dispose();
    _name.dispose();
    super.dispose();
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
                      if (!_linkSent) ...[
                        const Text(
                            'Entra com o teu email para aceitar o convite.',
                            style: TextStyle(color: AppTheme.textMuted)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _name,
                          decoration: const InputDecoration(
                              labelText: 'O teu nome (opcional)'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _email,
                          decoration: const InputDecoration(
                              labelText: 'Email *',
                              prefixIcon: Icon(Icons.email_outlined)),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        LoadingButton(
                            label: 'Entrar e aceitar', onPressed: _sendLink),
                      ] else ...[
                        const Icon(Icons.mark_email_read,
                            size: 56, color: AppTheme.primary),
                        const SizedBox(height: 16),
                        const Text(
                            'Enviamos um link de acesso ao teu email. Entra e volta aqui para aceitar o convite.',
                            textAlign: TextAlign.center),
                      ],
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
