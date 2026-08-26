import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../core/models/dose_log_model.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/extensions.dart';
import '../../providers/app_providers.dart';

class DoseHistoryPage extends ConsumerStatefulWidget {
  final String petId;
  const DoseHistoryPage({super.key, required this.petId});

  @override
  ConsumerState<DoseHistoryPage> createState() => _DoseHistoryPageState();
}

class _DoseHistoryPageState extends ConsumerState<DoseHistoryPage> {
  String _filter = 'week'; // today, week, month

  Future<List<Map<String, dynamic>>> _load() async {
    final hasPremium = await ref.read(hasPremiumProvider.future);
    DateTime start;
    switch (_filter) {
      case 'today':
        start = DateTime.now().dateOnly;
        break;
      case 'month':
        start = DateTime.now().subtract(const Duration(days: 30));
        break;
      default:
        start = DateTime.now().subtract(const Duration(days: 7));
    }
    // Free: limita a 7 dias
    if (!hasPremium) {
      final freeStart = DateTime.now().subtract(const Duration(days: AppConstants.freeHistoryDays));
      if (start.isBefore(freeStart)) start = freeStart;
    }
    final data = await SupabaseService.client
        .from('dose_logs')
        .select('id, scheduled_time, given_at, given_by, status, notes, '
            'medications(name)')
        .eq('pet_id', widget.petId)
        .lt('scheduled_time', DateTime.now().toUtc().toIso8601String())
        .gte('scheduled_time', start.toUtc().toIso8601String())
        .order('scheduled_time', ascending: false);

    // Resolver nomes de quem deu (given_by -> profiles.full_name)
    final rows = (data as List).cast<Map<String, dynamic>>();
    final givenByIds = rows
        .map((r) => r['given_by'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
    Map<String, String> names = {};
    if (givenByIds.isNotEmpty) {
      final profs = await SupabaseService.client
          .from('profiles')
          .select('id, full_name')
          .inFilter('id', givenByIds);
      for (final p in (profs as List)) {
        names[p['id'] as String] = (p['full_name'] as String?) ?? 'Utilizador';
      }
    }
    // Anexa o nome resolvido a cada linha
    for (final r in rows) {
      final gid = r['given_by'] as String?;
      r['_given_by_name'] = gid == null ? null : (names[gid] ?? 'Utilizador');
    }
    return rows;
  }

  Color _statusColor(DoseStatus s) {
    switch (s) {
      case DoseStatus.given:
        return Colors.green;
      case DoseStatus.missed:
        return AppTheme.danger;
      case DoseStatus.skipped:
        return AppTheme.textMuted;
      case DoseStatus.pending:
        return AppTheme.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historico')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'today', label: Text('Hoje')),
                ButtonSegment(value: 'week', label: Text('Semana')),
                ButtonSegment(value: 'month', label: Text('Mes')),
              ],
              selected: {_filter},
              onSelectionChanged: (s) => setState(() => _filter = s.first),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _load(),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) return Center(child: Text('Erro: ${snap.error}'));
                final rows = snap.data ?? [];
                if (rows.isEmpty) {
                  return const Center(child: Text('Sem registos neste periodo.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: rows.length,
                  itemBuilder: (_, i) {
                    final r = rows[i];
                    final status = DoseStatus.values.byName(
                        r['status'] as String? ?? 'pending');
                    final givenAt = r['given_at'] != null
                        ? DateTime.parse(r['given_at'] as String).toLocal()
                        : null;
                    final med = r['medications'] as Map<String, dynamic>?;
                    final givenByName = r['_given_by_name'] as String?;
                    String subtitle;
                    if (status == DoseStatus.given && givenAt != null) {
                      subtitle = givenByName != null
                          ? 'Dada por $givenByName em ${Formatters.dateTime(givenAt)}'
                          : 'Dada em ${Formatters.dateTime(givenAt)}';
                    } else {
                      subtitle = status.name.capitalize();
                    }
                    return ListTile(
                      leading: Icon(Icons.circle,
                          color: _statusColor(status), size: 14),
                      title: Text(med?['name'] as String? ?? 'Remedio'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(Formatters.dateTime(DateTime.parse(
                                  r['scheduled_time'] as String)
                              .toLocal())),
                          const SizedBox(height: 2),
                          Text(subtitle,
                              style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                      isThreeLine: true,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
