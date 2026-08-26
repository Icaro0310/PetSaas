import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../core/models/caregiver_model.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/extensions.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/empty_state.dart';

class CaregiversListPage extends ConsumerWidget {
  final String petId;
  const CaregiversListPage({super.key, required this.petId});

  Future<void> _remove(WidgetRef ref, CaregiverModel c) async {
    await SupabaseService.client
        .from('caregivers')
        .update({
          'status': 'removed',
          'removed_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', c.id);
    ref.invalidate(caregiversForPetProvider(petId));
  }

  @override
  Widget build(BuildContext context, ref) {
    final cgAsync = ref.watch(caregiversForPetProvider(petId));
    final list = cgAsync.valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Cuidadores')),
      body: cgAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (_) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.people_alt_outlined,
              title: 'Nenhum cuidador',
              subtitle: 'Convide alguem para ajudar a dar remedio ao pet.',
              actionLabel: 'Convidar cuidador',
              onAction: () => context.push('${AppRoutes.invite}/$petId'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _CaregiverTile(
              cg: list[i],
              onRemove: () => _remove(ref, list[i]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('${AppRoutes.invite}/$petId'),
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

class _CaregiverTile extends StatelessWidget {
  final CaregiverModel cg;
  final VoidCallback onRemove;
  const _CaregiverTile({required this.cg, required this.onRemove});

  Color _color(CaregiverStatus s) {
    switch (s) {
      case CaregiverStatus.active:
        return Colors.green;
      case CaregiverStatus.pending:
        return AppTheme.accent;
      case CaregiverStatus.removed:
        return AppTheme.textMuted;
    }
  }

  String _label(CaregiverStatus s) {
    switch (s) {
      case CaregiverStatus.active:
        return 'Ativo';
      case CaregiverStatus.pending:
        return 'Pendente';
      case CaregiverStatus.removed:
        return 'Removido';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _color(cg.status).withValues(alpha: 0.15),
          child: Icon(Icons.person, color: _color(cg.status)),
        ),
        title: Text(cg.caregiverEmail),
        subtitle: Text(_label(cg.status).capitalize()),
        trailing: cg.status != CaregiverStatus.removed
            ? IconButton(
                icon: const Icon(Icons.remove_circle_outline,
                    color: AppTheme.danger),
                onPressed: onRemove,
              )
            : null,
      ),
    );
  }
}
