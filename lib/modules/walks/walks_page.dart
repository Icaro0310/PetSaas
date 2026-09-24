import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme.dart';
import '../../core/models/walk_model.dart';
import '../../core/services/supabase_service.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/empty_state.dart';

class WalksPage extends ConsumerWidget {
  final String petId;
  const WalksPage({super.key, required this.petId});

  Future<void> _addWalk(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _WalkFormDialog(petId: petId),
    );
  }

  @override
  Widget build(BuildContext context, ref) {
    final walksAsync = ref.watch(walksForPetProvider(petId));
    final walks = walksAsync.valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Passeios')),
      body: walksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (_) {
          if (walks.isEmpty) {
            return EmptyState(
              icon: Icons.directions_walk,
              title: 'Sem passeios',
              subtitle: 'Registe o primeiro passeio deste pet.',
              actionLabel: 'Registar passeio',
              onAction: () => _addWalk(context),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: walks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _WalkCard(walk: walks[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addWalk(context),
        tooltip: 'Registar passeio',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _WalkCard extends StatelessWidget {
  final WalkModel walk;
  const _WalkCard({required this.walk});

  String _when() {
    final w = walk.walkedAt;
    final d = '${w.day.toString().padLeft(2, '0')}/'
        '${w.month.toString().padLeft(2, '0')}/${w.year}';
    final h = '${w.hour.toString().padLeft(2, '0')}:'
        '${w.minute.toString().padLeft(2, '0')}';
    return '$d $h';
  }

  Future<void> _delete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar passeio'),
        content: const Text('Quer mesmo eliminar este registo de passeio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await SupabaseService.client.from('walks').delete().eq('id', walk.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
          child: const Icon(Icons.directions_walk, color: AppTheme.primary),
        ),
        title: Text(
          _when(),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: [
                if (walk.poop) const _Tag(label: 'Cocô'),
                if (walk.pee) const _Tag(label: 'Xixi'),
                if (!walk.poop && !walk.pee)
                  const _Tag(label: 'Sem necessidades'),
                if (walk.durationMinutes != null)
                  _Tag(label: '${walk.durationMinutes} min'),
              ],
            ),
            if (walk.notes != null && walk.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(walk.notes!),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Eliminar passeio',
          onPressed: () => _delete(context),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

class _WalkFormDialog extends StatefulWidget {
  final String petId;
  const _WalkFormDialog({required this.petId});

  @override
  State<_WalkFormDialog> createState() => _WalkFormDialogState();
}

class _WalkFormDialogState extends State<_WalkFormDialog> {
  bool _poop = false;
  bool _pee = false;
  bool _saving = false;
  final _duration = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _duration.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = SupabaseService.currentUserId;
    if (user == null) return;
    setState(() => _saving = true);
    try {
      await SupabaseService.client.from('walks').insert({
        'pet_id': widget.petId,
        'walked_at': DateTime.now().toUtc().toIso8601String(),
        'poop': _poop,
        'pee': _pee,
        'duration_minutes': int.tryParse(_duration.text.trim()),
        'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        'logged_by': user,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro ao registar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registar passeio'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Cocô'),
              value: _poop,
              onChanged: (v) => setState(() => _poop = v ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              title: const Text('Xixi'),
              value: _pee,
              onChanged: (v) => setState(() => _pee = v ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            Semantics(
              label: 'Duracao (min, opcional)',
              textField: true,
              child: TextField(
                controller: _duration,
                decoration: const InputDecoration(
                  labelText: 'Duracao (min, opcional)',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const SizedBox(height: 8),
            Semantics(
              label: 'Notas (opcional)',
              textField: true,
              child: TextField(
                controller: _notes,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                ),
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: const Text('Registar'),
        ),
      ],
    );
  }
}
