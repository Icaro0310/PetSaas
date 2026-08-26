import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/deep_link_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/validators.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/loading_button.dart';

class InviteCaregiverPage extends ConsumerStatefulWidget {
  final String petId;
  const InviteCaregiverPage({super.key, required this.petId});

  @override
  ConsumerState<InviteCaregiverPage> createState() =>
      _InviteCaregiverPageState();
}

class _InviteCaregiverPageState extends ConsumerState<InviteCaregiverPage> {
  final _email = TextEditingController();
  String? _inviteUrl;

  Future<void> _invite() async {
    if (Validators.email(_email.text) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email invalido.')),
      );
      return;
    }

    // Gate: max 1 cuidador no Free
    final hasPremium = await ref.read(hasPremiumProvider.future);
    final existing = await SupabaseService.client
        .from('caregivers')
        .select()
        .eq('pet_id', widget.petId)
        .neq('status', 'removed');
    if (!hasPremium && (existing as List).length >= AppConstants.freeMaxCaregivers) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Free permite 1 cuidador. Assine Premium para mais.')),
        );
      }
      return;
    }

    final user = SupabaseService.currentUser;
    try {
      final res = await SupabaseService.client
          .from('caregivers')
          .insert({
            'pet_id': widget.petId,
            'owner_id': user!.id,
            'caregiver_email': _email.text.trim(),
            'status': 'pending',
            'permissions': ['view', 'mark_dose'],
          })
          .select()
          .single();
      final token = res['invite_token'] as String?;
      if (token != null) {
        setState(() => _inviteUrl = DeepLinkService.inviteUrl(token));
        await AnalyticsService.caregiverInvited();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Convidar cuidador')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _inviteUrl == null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Convide alguem para ajudar a dar remedio ao pet.',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _email,
                      decoration: const InputDecoration(
                        labelText: 'Email do cuidador *',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),
                    LoadingButton(
                        label: 'Enviar convite', onPressed: _invite),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle,
                        size: 56, color: AppTheme.primary),
                    const SizedBox(height: 16),
                    const Text('Convite criado!',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                      'Compartilhe este link com o cuidador. Ele precisara entrar com o mesmo email.',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(_inviteUrl!),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: _inviteUrl!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Link copiado!')),
                          );
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text('Copiar link'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Concluir'),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
