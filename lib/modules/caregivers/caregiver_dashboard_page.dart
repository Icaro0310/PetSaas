import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/supabase_service.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/empty_state.dart';

class CaregiverDashboardPage extends ConsumerStatefulWidget {
  const CaregiverDashboardPage({super.key});

  @override
  ConsumerState<CaregiverDashboardPage> createState() =>
      _CaregiverDashboardPageState();
}

class _CaregiverDashboardPageState
    extends ConsumerState<CaregiverDashboardPage> {
  List<Map<String, dynamic>> _assignments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = SupabaseService.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final data = await SupabaseService.client
          .from('caregivers')
          .select('pet_id, pets(id, name, photo_url)')
          .eq('caregiver_id', user.id)
          .eq('status', 'active');
      setState(() {
        _assignments = (data as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cuidador')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _assignments.isEmpty
              ? const EmptyState(
                  icon: Icons.people_alt_outlined,
                  title: 'Sem atribuicoes',
                  subtitle: 'Nao estas a cuidar de nenhum pet ainda.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _assignments.length,
                  itemBuilder: (_, i) {
                    final pet = _assignments[i]['pets'] as Map<String, dynamic>?;
                    if (pet == null) return const SizedBox.shrink();
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: pet['photo_url'] != null
                              ? NetworkImage(pet['photo_url'])
                              : null,
                          child: pet['photo_url'] == null
                              ? const Icon(Icons.pets, color: Colors.grey)
                              : null,
                        ),
                        title: Text(pet['name'] ?? 'Pet'),
                        subtitle: const Text('Voce cuida deste pet'),
                        onTap: () => _showPendingDoses(context, pet['id'], pet['name']),
                      ),
                    );
                  },
                ),
    );
  }

  void _showPendingDoses(BuildContext context, String petId, String petName) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _PendingDosesSheet(petId: petId, petName: petName),
    );
  }
}

class _PendingDosesSheet extends ConsumerStatefulWidget {
  final String petId;
  final String petName;
  const _PendingDosesSheet({required this.petId, required this.petName});

  @override
  ConsumerState<_PendingDosesSheet> createState() =>
      _PendingDosesSheetState();
}

class _PendingDosesSheetState extends ConsumerState<_PendingDosesSheet> {
  List<Map<String, dynamic>> _doses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final now = DateTime.now().toUtc();
    final end = DateTime.now().add(const Duration(days: 1)).toUtc();
    try {
      final data = await SupabaseService.client
          .from('dose_logs')
          .select('id, scheduled_time, status, medications(name)')
          .eq('pet_id', widget.petId)
          .eq('status', 'pending')
          .gte('scheduled_time', now.toIso8601String())
          .lt('scheduled_time', end.toIso8601String())
          .order('scheduled_time');
      setState(() {
        _doses = (data as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _markGiven(String doseId) async {
    final user = SupabaseService.currentUser;
    if (user == null) return;
    await SupabaseService.client.rpc('mark_dose_given', params: {
      'p_dose_id': doseId,
      'p_user_id': user.id,
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _doses.isEmpty
              ? Center(child: Text('Sem doses pendentes para ${widget.petName}'))
              : ListView.builder(
                  itemCount: _doses.length,
                  itemBuilder: (_, i) {
                    final d = _doses[i];
                    final med = d['medications'] as Map<String, dynamic>?;
                    final time = DateTime.parse(d['scheduled_time']).toLocal();
                    return ListTile(
                      title: Text(med?['name'] ?? 'Remedio'),
                      subtitle: Text(Formatters.time(time)),
                      trailing: ElevatedButton(
                        onPressed: () => _markGiven(d['id']),
                        child: const Text('Dar'),
                      ),
                    );
                  },
                ),
    );
  }
}
