import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../core/models/pet_model.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/extensions.dart';
import '../../providers/app_providers.dart';

class PetDetailPage extends ConsumerWidget {
  final String petId;
  const PetDetailPage({super.key, required this.petId});

  @override
  Widget build(BuildContext context, ref) {
    ref.watch(selectedPetIdProvider.notifier).state = petId;
    final pet = ref.watch(selectedPetProvider);
    final isOwner = ref.watch(isOwnerOfSelectedPetProvider).valueOrNull ?? true;

    return Scaffold(
      appBar: AppBar(
        title: Text(pet?.name ?? 'Pet'),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push('${AppRoutes.petEdit}/$petId'),
            ),
        ],
      ),
      body: pet == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 240,
                    color: Colors.grey.shade200,
                    child: pet.photoUrl != null
                        ? Image.network(pet.photoUrl!, fit: BoxFit.cover)
                        : const Icon(Icons.pets, size: 80, color: Colors.grey),
                  ),
                  if (pet.isLost)
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
                  if (!isOwner)
                    Container(
                      width: double.infinity,
                      color: AppTheme.secondary.withValues(alpha: 0.12),
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'Voce cuida do ${pet.name}. Pode ver e marcar doses.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.secondary),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.name,
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${pet.species.name.capitalize()} - ${pet.breed ?? 'Sem raca'} - ${Formatters.age(pet.birthDate)}',
                          style: const TextStyle(color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 20),
                        _ActionGrid(pet: pet, isOwner: isOwner),
                        const SizedBox(height: 24),
                        _InfoSection(pet: pet),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  final PetModel pet;
  final bool isOwner;
  const _ActionGrid({required this.pet, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      _ActionCard(
        icon: Icons.medication,
        label: 'Medicamentos',
        onTap: () => context.push('${AppRoutes.medications}/${pet.id}'),
      ),
      _ActionCard(
        icon: Icons.history,
        label: 'Historico',
        onTap: () => context.push('${AppRoutes.history}/${pet.id}'),
      ),
    ];
    // Apenas dono ve QR Code e Cuidadores
    if (isOwner) {
      actions.insert(
        1,
        _ActionCard(
          icon: Icons.qr_code_2,
          label: 'QR Code',
          onTap: () => context.push('${AppRoutes.qr}/${pet.id}'),
        ),
      );
      actions.add(
        _ActionCard(
          icon: Icons.people_alt_outlined,
          label: 'Cuidadores',
          onTap: () => context.push('${AppRoutes.caregivers}/${pet.id}'),
        ),
      );
    }
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: actions,
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: AppTheme.primary),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final PetModel pet;
  const _InfoSection({required this.pet});

  Widget _row(String label, String? value) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(color: AppTheme.textMuted)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row('Peso', Formatters.weight(pet.weightKg)),
        _row('Cor', pet.color),
        _row('Microchip', pet.microchipId),
        _row('Alergias', pet.allergies),
        _row('Med. critica', pet.criticalMeds),
        _row('Avisos', pet.warnings),
        _row('Emergencia', pet.emergencyInfo),
        _row('Veterinario', pet.vetName),
        _row('Tel. vet', pet.vetPhone),
        _row('Descricao', pet.description),
      ],
    );
  }
}
