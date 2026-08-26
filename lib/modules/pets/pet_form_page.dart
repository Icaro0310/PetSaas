import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/pet_model.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/validators.dart';
import '../../shared/widgets/loading_button.dart';
import '../../shared/widgets/photo_picker.dart';

class PetFormPage extends ConsumerStatefulWidget {
  final String? petId;
  const PetFormPage({super.key, this.petId});

  @override
  ConsumerState<PetFormPage> createState() => _PetFormPageState();
}

class _PetFormPageState extends ConsumerState<PetFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _breed = TextEditingController();
  final _weight = TextEditingController();
  final _color = TextEditingController();
  final _description = TextEditingController();
  final _emergencyInfo = TextEditingController();
  final _allergies = TextEditingController();
  final _criticalMeds = TextEditingController();
  final _warnings = TextEditingController();
  final _microchip = TextEditingController();
  final _vetName = TextEditingController();
  final _vetPhone = TextEditingController();

  PetSpecies _species = PetSpecies.dog;
  DateTime? _birthDate;
  String? _photoPath;
  String? _existingPhotoUrl;
  bool _saving = false;
  bool _loading = false;

  bool get _isEdit => widget.petId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) _loadPet();
  }

  Future<void> _loadPet() async {
    setState(() => _loading = true);
    try {
      final data = await SupabaseService.client
          .from('pets')
          .select()
          .eq('id', widget.petId!)
          .single();
      final pet = PetModel.fromJson(data);
      _name.text = pet.name;
      _breed.text = pet.breed ?? '';
      _weight.text = pet.weightKg != null ? pet.weightKg.toString() : '';
      _color.text = pet.color ?? '';
      _description.text = pet.description ?? '';
      _emergencyInfo.text = pet.emergencyInfo ?? '';
      _allergies.text = pet.allergies ?? '';
      _criticalMeds.text = pet.criticalMeds ?? '';
      _warnings.text = pet.warnings ?? '';
      _microchip.text = pet.microchipId ?? '';
      _vetName.text = pet.vetName ?? '';
      _vetPhone.text = pet.vetPhone ?? '';
      _species = pet.species;
      _birthDate = pet.birthDate;
      _existingPhotoUrl = pet.photoUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro ao carregar: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2020),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _birthDate = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = SupabaseService.currentUser;
    if (user == null) return;
    setState(() => _saving = true);

    try {
      String? photoUrl = _existingPhotoUrl;

      // Upload da foto se houver nova
      if (_photoPath != null) {
        final file = File(_photoPath!);
        final ext = _photoPath!.split('.').last.toLowerCase();
        final tempId = widget.petId ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';
        photoUrl = await SupabaseService.uploadPetPhoto(
          petId: tempId,
          filePath: _photoPath!,
          fileExt: ext,
        );
        // best-effort; ignore unused
        file;
      }

      final payload = <String, dynamic>{
        'owner_id': user.id,
        'name': _name.text.trim(),
        'species': _species.name,
        'breed': _breed.text.trim().isEmpty ? null : _breed.text.trim(),
        'birth_date': _birthDate?.toIso8601String().split('T').first,
        'weight_kg': double.tryParse(_weight.text.replaceAll(',', '.')),
        'color': _color.text.trim().isEmpty ? null : _color.text.trim(),
        'description':
            _description.text.trim().isEmpty ? null : _description.text.trim(),
        'emergency_info': _emergencyInfo.text.trim().isEmpty
            ? null
            : _emergencyInfo.text.trim(),
        'allergies':
            _allergies.text.trim().isEmpty ? null : _allergies.text.trim(),
        'critical_meds': _criticalMeds.text.trim().isEmpty
            ? null
            : _criticalMeds.text.trim(),
        'warnings':
            _warnings.text.trim().isEmpty ? null : _warnings.text.trim(),
        'microchip_id':
            _microchip.text.trim().isEmpty ? null : _microchip.text.trim(),
        'vet_name': _vetName.text.trim().isEmpty ? null : _vetName.text.trim(),
        'vet_phone':
            _vetPhone.text.trim().isEmpty ? null : _vetPhone.text.trim(),
        'photo_url': photoUrl,
      };

      if (_isEdit) {
        await SupabaseService.client
            .from('pets')
            .update(payload)
            .eq('id', widget.petId!);
      } else {
        await SupabaseService.client.from('pets').insert(payload);
        await AnalyticsService.petCreated();
      }

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

  @override
  void dispose() {
    _name.dispose();
    _breed.dispose();
    _weight.dispose();
    _color.dispose();
    _description.dispose();
    _emergencyInfo.dispose();
    _allergies.dispose();
    _criticalMeds.dispose();
    _warnings.dispose();
    _microchip.dispose();
    _vetName.dispose();
    _vetPhone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Editar pet' : 'Novo pet')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: PhotoPicker(
                    currentUrl: _existingPhotoUrl,
                    localPath: _photoPath,
                    onChanged: (p) => _photoPath = p,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Nome *'),
                  validator: (v) => Validators.required(v, label: 'Nome obrigatorio'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: RadioMenuButton(
                        value: PetSpecies.dog,
                        groupValue: _species,
                        onChanged: (v) =>
                            setState(() => _species = v ?? PetSpecies.dog),
                        child: const Text('Cao'),
                      ),
                    ),
                    Expanded(
                      child: RadioMenuButton(
                        value: PetSpecies.cat,
                        groupValue: _species,
                        onChanged: (v) =>
                            setState(() => _species = v ?? PetSpecies.dog),
                        child: const Text('Gato'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _breed,
                  decoration: const InputDecoration(labelText: 'Raca'),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data de nascimento',
                      prefixIcon: Icon(Icons.cake_outlined),
                    ),
                    child: Text(
                      _birthDate == null
                          ? 'Selecionar data'
                          : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _weight,
                  decoration: const InputDecoration(
                      labelText: 'Peso (kg)', prefixText: ''),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => Validators.positiveNumber(v),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _color,
                  decoration: const InputDecoration(labelText: 'Cor'),
                ),
                const SizedBox(height: 20),
                const _SectionTitle('Saude'),
                TextFormField(
                  controller: _allergies,
                  decoration: const InputDecoration(
                      labelText: 'Alergias', prefixIcon: Icon(Icons.warning_amber)),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _criticalMeds,
                  decoration: const InputDecoration(
                      labelText: 'Medicacao critica',
                      prefixIcon: Icon(Icons.medication)),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emergencyInfo,
                  decoration: const InputDecoration(
                      labelText: 'Info de emergencia',
                      prefixIcon: Icon(Icons.emergency)),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _warnings,
                  decoration: const InputDecoration(
                      labelText: 'Avisos', prefixIcon: Icon(Icons.info_outline)),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                const _SectionTitle('Veterinario'),
                TextFormField(
                  controller: _vetName,
                  decoration: const InputDecoration(labelText: 'Nome do veterinario'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _vetPhone,
                  decoration: const InputDecoration(labelText: 'Telefone do veterinario'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _microchip,
                  decoration: const InputDecoration(labelText: 'Microchip ID'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  decoration: const InputDecoration(labelText: 'Descricao'),
                  maxLines: 3,
                ),
                const SizedBox(height: 28),
                LoadingButton(
                  label: _isEdit ? 'Guardar alteracoes' : 'Criar pet',
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

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
