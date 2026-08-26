import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../core/models/medication_model.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/empty_state.dart';

class MedicationsListPage extends ConsumerWidget {
  final String petId;
  const MedicationsListPage({super.key, required this.petId});

  @override
  Widget build(BuildContext context, ref) {
    final medsAsync = ref.watch(medicationsForPetProvider(petId));
    final meds = medsAsync.valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Medicamentos')),
      body: medsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (_) {
          if (meds.isEmpty) {
            return EmptyState(
              icon: Icons.medication,
              title: 'Sem medicamentos',
              subtitle: 'Adicione o primeiro remedio para este pet.',
              actionLabel: 'Adicionar remedio',
              onAction: () =>
                  context.push('${AppRoutes.medicationNew}/$petId'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: meds.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _MedCard(med: meds[i], petId: petId),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('${AppRoutes.medicationNew}/$petId'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MedCard extends StatelessWidget {
  final MedicationModel med;
  final String petId;
  const _MedCard({required this.med, required this.petId});

  String _freqLabel() {
    switch (med.frequencyType) {
      case FrequencyType.daily:
        return 'Diario - ${med.scheduleTimes.join(', ')}';
      case FrequencyType.weekly:
        return 'Semanal';
      case FrequencyType.interval_hours:
        return 'A cada ${med.frequencyValue}h';
      case FrequencyType.as_needed:
        return 'Conforme necessario';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
          child: const Icon(Icons.medication, color: AppTheme.primary),
        ),
        title: Text(med.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${med.dosage} - ${_freqLabel()}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  med.isActive ? Icons.check_circle : Icons.pause_circle,
                  size: 16,
                  color: med.isActive ? Colors.green : AppTheme.textMuted,
                ),
                const SizedBox(width: 4),
                Text(med.isActive ? 'Ativo' : 'Pausado',
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        onTap: () => context.push('${AppRoutes.medicationNew}/$petId'),
      ),
    );
  }
}
