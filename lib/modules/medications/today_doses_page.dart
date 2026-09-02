import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../core/models/dose_log_model.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/formatters.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/photo_picker.dart';

class TodayDosesPage extends ConsumerStatefulWidget {
  const TodayDosesPage({super.key});

  @override
  ConsumerState<TodayDosesPage> createState() => _TodayDosesPageState();
}

class _TodayDosesPageState extends ConsumerState<TodayDosesPage> {
  Future<void> _refresh() async {
    ref.invalidate(todayDosesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final dosesAsync = ref.watch(todayDosesProvider);
    final pets = ref.watch(petsProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doses de hoje'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push(AppRoutes.profile),
          ),
        ],
      ),
      body: dosesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (doses) {
          if (doses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 72, color: AppTheme.primary),
                  const SizedBox(height: 16),
                  const Text('Nenhuma dose para hoje',
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  const Text('Tudo em dia por aqui!',
                      style: TextStyle(color: AppTheme.textMuted)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => context.push(AppRoutes.pets),
                    icon: const Icon(Icons.pets),
                    label: const Text('Ver meus pets'),
                  ),
                ],
              ),
            );
          }
          // Agrupar por pet
          final byPet = <String, List<DoseLogModel>>{};
          for (final d in doses) {
            byPet.putIfAbsent(d.petId, () => []).add(d);
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: byPet.entries.map((e) {
              final pet = pets.where((p) => p.id == e.key).firstOrNull;
              return _PetDoseGroup(
                petName: pet?.name ?? 'Pet',
                petId: e.key,
                doses: e.value,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _PetDoseGroup extends ConsumerWidget {
  final String petName;
  final String petId;
  final List<DoseLogModel> doses;
  const _PetDoseGroup({
    required this.petName,
    required this.petId,
    required this.doses,
  });

  @override
  Widget build(BuildContext context, ref) {
    final medsAsync = ref.watch(medicationsForPetProvider(petId));
    final meds = medsAsync.valueOrNull ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Text(
            petName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...doses.map((d) {
          final med = meds.where((m) => m.id == d.medicationId).firstOrNull;
          return _DoseCard(
            dose: d,
            medName: med?.name ?? 'Remedio',
            dosage: med?.dosage ?? '',
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _DoseCard extends ConsumerWidget {
  final DoseLogModel dose;
  final String medName;
  final String dosage;
  const _DoseCard({
    required this.dose,
    required this.medName,
    required this.dosage,
  });

  Color _statusColor(DoseStatus s) {
    switch (s) {
      case DoseStatus.pending:
        return AppTheme.accent;
      case DoseStatus.given:
        return Colors.green;
      case DoseStatus.missed:
        return AppTheme.danger;
      case DoseStatus.skipped:
        return AppTheme.textMuted;
    }
  }

  String _statusLabel(DoseStatus s) {
    switch (s) {
      case DoseStatus.pending:
        return 'Pendente';
      case DoseStatus.given:
        return 'Dada';
      case DoseStatus.missed:
        return 'Perdida';
      case DoseStatus.skipped:
        return 'Ignorada';
    }
  }

  @override
  Widget build(BuildContext context, ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: _statusColor(dose.status).withValues(alpha: 0.15),
              child: Icon(Icons.medication, color: _statusColor(dose.status)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(medName,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('$dosage - ${Formatters.time(dose.scheduledTime.toLocal())}',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(_statusLabel(dose.status),
                      style: TextStyle(
                          color: _statusColor(dose.status), fontSize: 12)),
                ],
              ),
            ),
            if (dose.status == DoseStatus.pending)
              ElevatedButton(
                onPressed: () => _showConfirm(context, ref),
                child: const Text('Dar remedio'),
              ),
          ],
        ),
      ),
    );
  }

  void _showConfirm(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ConfirmDoseSheet(
        dose: dose,
        medName: medName,
        onConfirm: ({photoUrl, notes}) async {
          final user = SupabaseService.currentUserId;
          if (user == null) return;
          await SupabaseService.client.rpc('mark_dose_given', params: {
            'p_dose_id': dose.id,
            'p_user_id': user,
            'p_photo_url': photoUrl,
            'p_notes': notes,
          });
          await NotificationService.cancelReminder(dose.id.hashCode);
          await AnalyticsService.doseMarkedGiven();
          ref.invalidate(todayDosesProvider);
        },
      ),
    );
  }
}

class _ConfirmDoseSheet extends ConsumerStatefulWidget {
  final DoseLogModel dose;
  final String medName;
  final Future<void> Function({String? photoUrl, String? notes}) onConfirm;
  const _ConfirmDoseSheet({
    required this.dose,
    required this.medName,
    required this.onConfirm,
  });

  @override
  ConsumerState<_ConfirmDoseSheet> createState() => _ConfirmDoseSheetState();
}

class _ConfirmDoseSheetState extends ConsumerState<_ConfirmDoseSheet> {
  final _notes = TextEditingController();
  bool _saving = false;
  String? _photoPath;
  bool _hasPremium = false;

  @override
  void initState() {
    super.initState();
    _checkPremium();
  }

  Future<void> _checkPremium() async {
    final premium = await ref.read(hasPremiumProvider.future);
    if (mounted) setState(() => _hasPremium = premium);
  }

  Future<void> _confirm() async {
    setState(() => _saving = true);
    try {
      String? photoUrl;
      if (_photoPath != null && _hasPremium) {
        final ext = _photoPath!.split('.').last.toLowerCase();
        photoUrl = await SupabaseService.uploadPetPhoto(
          petId: widget.dose.petId,
          filePath: _photoPath!,
          fileExt: ext,
        );
      }
      await widget.onConfirm(
        photoUrl: photoUrl,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Marcar dose como dada',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(widget.medName),
          const SizedBox(height: 16),
          if (_hasPremium) ...[
            PhotoPicker(
              localPath: _photoPath,
              onChanged: (p) => setState(() => _photoPath = p),
              size: 100,
            ),
            const SizedBox(height: 12),
          ] else ...[
            Row(
              children: [
                const Icon(Icons.lock_outline, size: 18, color: AppTheme.accent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Foto na dose e Premium',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _notes,
            decoration: const InputDecoration(labelText: 'Notas (opcional)'),
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _confirm,
              child: _saving
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Confirmar'),
            ),
          ),
        ],
      ),
    );
  }
}
