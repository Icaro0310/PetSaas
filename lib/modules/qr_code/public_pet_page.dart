import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../config/theme.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/supabase_service.dart';
import '../../shared/widgets/loading_button.dart';

class PublicPetPage extends StatefulWidget {
  final String uuid;
  const PublicPetPage({super.key, required this.uuid});

  @override
  State<PublicPetPage> createState() => _PublicPetPageState();
}

class _PublicPetPageState extends State<PublicPetPage> {
  Map<String, dynamic>? _pet;
  bool _loading = true;
  String? _error;
  bool _foundFormOpen = false;
  bool _submitted = false;

  final _name = TextEditingController();
  final _contact = TextEditingController();
  final _message = TextEditingController();
  double? _lat;
  double? _lng;
  String? _locationApprox;

  @override
  void initState() {
    super.initState();
    _loadPet();
  }

  Future<void> _loadPet() async {
    try {
      final data = await SupabaseService.client
          .from('pets')
          .select()
          .eq('qr_code_uuid', widget.uuid)
          .maybeSingle();
      if (data == null) {
        _error = 'Pet nao encontrado.';
      } else {
        _pet = data;
      }
    } catch (e) {
      _error = 'Erro: $e';
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _getLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Localizacao desativada.')),
          );
        }
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        // Localizacao aproximada: arredonda para 1 casa decimal (~11km)
        _locationApprox =
            '${pos.latitude.toStringAsFixed(1)}, ${pos.longitude.toStringAsFixed(1)}';
      });
    } catch (_) {}
  }

  Future<void> _submitFound() async {
    if (_name.text.trim().isEmpty || _message.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o nome e a mensagem.')),
      );
      return;
    }
    try {
      await SupabaseService.client.functions.invoke(
        'notify-pet-found',
        body: {
          'qr_code_uuid': widget.uuid,
          'finder_name': _name.text.trim(),
          'finder_email': _contact.text.trim().isEmpty ? null : _contact.text.trim(),
          'message': _message.text.trim(),
          'location_lat': _lat,
          'location_lng': _lng,
        },
      );
      setState(() => _submitted = true);
      await AnalyticsService.petFoundMessageSent();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro ao enviar: $e')));
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _contact.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_error!, textAlign: TextAlign.center),
          ),
        ),
      );
    }
    final pet = _pet!;
    final isLost = pet['is_lost'] == true;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (pet['photo_url'] != null)
                Image.network(pet['photo_url'],
                    width: double.infinity, height: 220, fit: BoxFit.cover)
              else
                Container(
                  width: double.infinity,
                  height: 220,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.pets, size: 80, color: Colors.grey),
                ),
              if (isLost)
                Container(
                  width: double.infinity,
                  color: AppTheme.danger,
                  padding: const EdgeInsets.all(12),
                  child: const Text(
                    'ESTE PET ESTA PERDIDO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: _submitted
                    ? _successView()
                    : _foundFormOpen
                        ? _foundForm(pet)
                        : _infoView(pet),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoView(Map<String, dynamic> pet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(pet['name'] as String,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _row('Descricao', pet['description']),
        _row('Info de emergencia', pet['emergency_info']),
        _row('Alergias', pet['allergies']),
        _row('Medicacao critica', pet['critical_meds']),
        _row('Avisos', pet['warnings']),
        _row('Microchip', pet['microchip_id']),
        const SizedBox(height: 24),
        const Text(
          'Os dados do dono nao sao exibidos para sua privacidade.',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => setState(() => _foundFormOpen = true),
            icon: const Icon(Icons.pets),
            label: const Text('Encontrei este pet'),
          ),
        ),
      ],
    );
  }

  Widget _row(String label, dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          const SizedBox(height: 2),
          Text(value.toString()),
        ],
      ),
    );
  }

  Widget _foundForm(Map<String, dynamic> pet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Avisar o dono',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(
          'O dono sera notificado instantaneamente. Sua localizacao e enviada de forma aproximada.',
          style: TextStyle(color: AppTheme.textMuted),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Seu nome *'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _contact,
          decoration: const InputDecoration(
              labelText: 'Email ou telefone (opcional)'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _message,
          decoration: const InputDecoration(labelText: 'Mensagem *'),
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _getLocation,
              icon: const Icon(Icons.my_location),
              label: Text(_locationApprox == null
                  ? 'Enviar localizacao'
                  : 'Local: $_locationApprox'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        LoadingButton(label: 'Enviar aviso', onPressed: _submitFound),
      ],
    );
  }

  Widget _successView() {
    return Column(
      children: [
        const Icon(Icons.check_circle, size: 72, color: AppTheme.primary),
        const SizedBox(height: 16),
        const Text('O dono foi notificado!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(
          'Obrigado por ajudar. O dono entrara em contato se necessario.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textMuted),
        ),
      ],
    );
  }
}
