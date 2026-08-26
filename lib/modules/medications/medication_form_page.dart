import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../core/models/medication_model.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/validators.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/loading_button.dart';

class MedicationFormPage extends ConsumerStatefulWidget {
  final String petId;
  const MedicationFormPage({super.key, required this.petId});

  @override
  ConsumerState<MedicationFormPage> createState() => _MedicationFormPageState();
}

class _MedicationFormPageState extends ConsumerState<MedicationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _dosage = TextEditingController();
  final _instructions = TextEditingController();
  final _intervalHours = TextEditingController(text: '8');

  FrequencyType _freq = FrequencyType.daily;
  List<String> _times = ['08:00'];
  Set<int> _weekdays = {1}; // segunda
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _active = true;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _dosage.dispose();
    _instructions.dispose();
    _intervalHours.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : (_endDate ?? _startDate),
      firstDate: isStart ? DateTime(2020) : _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) {
      setState(() {
        if (isStart) {
          _startDate = d;
        } else {
          _endDate = d;
        }
      });
    }
  }

  Future<void> _pickTime(int index) async {
    final initial = _parseTime(_times[index]);
    final t = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (t != null) {
      setState(() {
        _times[index] =
            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  TimeOfDay _parseTime(String s) {
    final parts = s.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Gate: medicacao e Premium
    final hasPremium = await ref.read(hasPremiumProvider.future);
    if (!hasPremium) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medicacao e uma funcionalidade Premium.'),
          ),
        );
        context.push(AppRoutes.subscription);
      }
      return;
    }

    setState(() => _saving = true);
    try {
      final scheduleTimes = _freq == FrequencyType.daily
          ? _times
          : _freq == FrequencyType.weekly
              ? _weekdays.map((d) => d.toString()).toList()
              : <String>[];

      final payload = {
        'pet_id': widget.petId,
        'name': _name.text.trim(),
        'dosage': _dosage.text.trim(),
        'instructions':
            _instructions.text.trim().isEmpty ? null : _instructions.text.trim(),
        'frequency_type': _freq.name,
        'frequency_value': _freq == FrequencyType.interval_hours
            ? int.tryParse(_intervalHours.text)
            : null,
        'schedule_times': scheduleTimes,
        'start_date': _startDate.toIso8601String().split('T').first,
        'end_date': _endDate?.toIso8601String().split('T').first,
        'is_active': _active,
      };

      final res = await SupabaseService.client
          .from('medications')
          .insert(payload)
          .select()
          .single();
      final medId = res['id'] as String;

      // Iniciar trial automatico na primeira medicacao
      await _ensureTrial();

      // Gerar dose_logs para os proximos 30 dias
      await _generateDoseLogs(medId);

      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro ao guardar: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _ensureTrial() async {
    final user = SupabaseService.currentUser;
    if (user == null) return;
    final existing = await SupabaseService.client
        .from('subscriptions')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();
    if (existing == null) {
      await SupabaseService.client.from('subscriptions').insert({
        'user_id': user.id,
        'status': 'trialing',
        'plan': 'premium',
        'current_period_start': DateTime.now().toIso8601String(),
        'current_period_end': DateTime.now()
            .add(const Duration(days: AppConstants.trialDays))
            .toIso8601String(),
      });
    }
  }

  Future<void> _generateDoseLogs(String medId) async {
    final now = DateTime.now();
    final horizon = now.add(const Duration(days: 30));
    final endBoundary = _endDate != null && _endDate!.isBefore(horizon)
        ? _endDate!
        : horizon;

    final List<Map<String, dynamic>> logs = [];

    if (_freq == FrequencyType.as_needed) {
      // Sem doses agendadas
    } else if (_freq == FrequencyType.daily) {
      for (final t in _times) {
        final parts = t.split(':');
        final h = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        for (int i = 0; i < 30; i++) {
          final day = DateTime(now.year, now.month, now.day + i, h, m);
          if (day.isAfter(endBoundary)) break;
          logs.add({
            'medication_id': medId,
            'pet_id': widget.petId,
            'scheduled_time': day.toUtc().toIso8601String(),
            'status': 'pending',
          });
        }
      }
    } else if (_freq == FrequencyType.weekly) {
      for (int i = 0; i < 30; i++) {
        final day = DateTime(now.year, now.month, now.day + i, 8, 0);
        if (day.isAfter(endBoundary)) break;
        if (_weekdays.contains(day.weekday)) {
          logs.add({
            'medication_id': medId,
            'pet_id': widget.petId,
            'scheduled_time': day.toUtc().toIso8601String(),
            'status': 'pending',
          });
        }
      }
    } else if (_freq == FrequencyType.interval_hours) {
      final interval = int.tryParse(_intervalHours.text) ?? 8;
      var t = DateTime(now.year, now.month, now.day, now.hour);
      while (t.isBefore(endBoundary)) {
        logs.add({
          'medication_id': medId,
          'pet_id': widget.petId,
          'scheduled_time': t.toUtc().toIso8601String(),
          'status': 'pending',
        });
        t = t.add(Duration(hours: interval));
      }
    }

    if (logs.isNotEmpty) {
      await SupabaseService.client.from('dose_logs').insert(logs);
    }

    // Agendar notificacoes locais (limite: proximas 50)
    var notifId = (medId.hashCode).abs();
    for (final log in logs.take(50)) {
      final sched = DateTime.parse(log['scheduled_time'] as String);
      await NotificationService.scheduleDoseReminder(
        id: notifId++,
        petName: '',
        medName: _name.text,
        scheduledTime: sched,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo remedio')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Nome do remedio *'),
                  validator: (v) => Validators.required(v, label: 'Obrigatorio'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _dosage,
                  decoration: const InputDecoration(labelText: 'Dosagem * (ex: 1 comprimido)'),
                  validator: (v) => Validators.required(v, label: 'Obrigatorio'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _instructions,
                  decoration: const InputDecoration(labelText: 'Instrucoes'),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                const Text('Frequencia',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SegmentedButton<FrequencyType>(
                  segments: const [
                    ButtonSegment(
                        value: FrequencyType.daily, label: Text('Diario')),
                    ButtonSegment(
                        value: FrequencyType.weekly, label: Text('Semanal')),
                    ButtonSegment(
                        value: FrequencyType.interval_hours,
                        label: Text('Intervalo')),
                    ButtonSegment(
                        value: FrequencyType.as_needed,
                        label: Text('Conforme')),
                  ],
                  selected: {_freq},
                  onSelectionChanged: (s) =>
                      setState(() => _freq = s.first),
                ),
                const SizedBox(height: 16),
                if (_freq == FrequencyType.daily) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Horarios'),
                      IconButton(
                        icon: const Icon(Icons.add_alarm),
                        onPressed: () =>
                            setState(() => _times.add('12:00')),
                      ),
                    ],
                  ),
                  ..._times.asMap().entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _pickTime(e.key),
                              child: Text(e.value),
                            ),
                          ),
                          if (_times.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: AppTheme.danger),
                              onPressed: () =>
                                  setState(() => _times.removeAt(e.key)),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
                if (_freq == FrequencyType.weekly) ...[
                  const Text('Dias da semana'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: List.generate(7, (i) {
                      final wd = i + 1;
                      final labels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];
                      final selected = _weekdays.contains(wd);
                      return FilterChip(
                        label: Text(labels[i]),
                        selected: selected,
                        onSelected: (v) => setState(() {
                          if (v) {
                            _weekdays.add(wd);
                          } else {
                            _weekdays.remove(wd);
                          }
                        }),
                      );
                    }),
                  ),
                ],
                if (_freq == FrequencyType.interval_hours) ...[
                  TextFormField(
                    controller: _intervalHours,
                    decoration: const InputDecoration(
                        labelText: 'A cada quantas horas?'),
                    keyboardType: TextInputType.number,
                    validator: (v) => Validators.required(v, label: 'Obrigatorio'),
                  ),
                ],
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _pickDate(isStart: true),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Data de inicio'),
                    child: Text(
                        '${_startDate.day}/${_startDate.month}/${_startDate.year}'),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => _pickDate(isStart: false),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                        labelText: 'Data de fim (opcional)'),
                    child: Text(_endDate == null
                        ? 'Sem fim'
                        : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Ativo'),
                  value: _active,
                  onChanged: (v) => setState(() => _active = v),
                ),
                const SizedBox(height: 24),
                LoadingButton(
                  label: 'Guardar remedio',
                  onPressed: _saving ? () async {} : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
