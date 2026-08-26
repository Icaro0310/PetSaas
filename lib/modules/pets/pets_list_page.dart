import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../core/models/pet_model.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/extensions.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/empty_state.dart';

class PetsListPage extends ConsumerWidget {
  const PetsListPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final petsAsync = ref.watch(petsProvider);
    final premiumAsync = ref.watch(hasPremiumProvider);
    final pets = petsAsync.valueOrNull ?? [];
    final hasPremium = premiumAsync.valueOrNull ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Meus pets')),
      body: petsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (_) {
          if (pets.isEmpty) {
            return EmptyState(
              icon: Icons.pets,
              title: 'Nenhum pet ainda',
              subtitle: 'Adicione o seu primeiro pet para comecar.',
              actionLabel: 'Adicionar pet',
              onAction: () => context.push(AppRoutes.petNew),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: pets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _PetCard(pet: pets[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final canAdd = hasPremium || pets.isEmpty;
          if (!canAdd) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Plano Free permite 1 pet. Assine o Premium para mais.'),
              ),
            );
            context.push(AppRoutes.subscription);
            return;
          }
          context.push(AppRoutes.petNew);
        },
        icon: const Icon(Icons.add),
        label: const Text('Adicionar pet'),
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final PetModel pet;
  const _PetCard({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('${AppRoutes.petDetail}/${pet.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: pet.photoUrl != null
                    ? NetworkImage(pet.photoUrl!)
                    : null,
                child: pet.photoUrl == null
                    ? const Icon(Icons.pets, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pet.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (pet.isLost)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.danger,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'PERDIDO',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 11),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pet.species.name.capitalize()} - ${Formatters.age(pet.birthDate)}',
                      style: const TextStyle(color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
