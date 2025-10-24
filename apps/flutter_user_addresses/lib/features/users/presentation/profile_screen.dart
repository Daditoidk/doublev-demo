import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_user_addresses/features/users/user_provider.dart';
import '../../users/user_models.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  Future<void> _editLastName(
    BuildContext context,
    WidgetRef ref,
    UserDto user,
  ) async {
    final controller = TextEditingController(text: user.lastName);
    final newLast = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Apellido'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Apellido'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (newLast == null || newLast.isEmpty) return;

    final updated = UserDto(
      id: user.id,
      firstName: user.firstName,
      lastName: newLast,
      birthDate: user.birthDate,
      addresses: user.addresses,
    );
    await ref.read(userActionsProvider).update(updated);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Actualizado')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);
    final selectedId = ref.watch(selectedUserIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil (lista de usuarios)')),
      body: users.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text('No hay usuarios. Crea uno en Onboarding.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemBuilder: (_, i) {
              final u = list[i];
              final isSelected = u.id == selectedId;
              return Card(
                child: ListTile(
                  title: Text('${u.firstName} ${u.lastName}'),
                  subtitle: Text('Direcciones: ${u.addresses.length}'),
                  selected: isSelected,
                  onTap: () =>
                      ref.read(selectedUserIdProvider.notifier).set(u.id),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editLastName(context, ref, u),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Eliminar'),
                              content: Text('¿Eliminar a ${u.firstName}?'),
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
                            await ref.read(userActionsProvider).delete(u.id!);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Eliminado')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: list.length,
          );
        },
      ),
    );
  }
}
