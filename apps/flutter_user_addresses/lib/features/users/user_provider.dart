import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_user_addresses/features/users/users_api.dart';
import 'user_models.dart';

/// DI for the API (easy to mock in tests)
final userApiProvider = Provider<UserApi>((ref) => UserApi());

/// List of users
final usersProvider = FutureProvider<List<UserDto>>((ref) async {
  final api = ref.read(userApiProvider);
  return api.list();
});

class SelectedUserIdNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void set(int? id) => state = id;

  void clear() => state = null;
}

/// Selected user id (set from UI when the user taps a list item)
final selectedUserIdProvider =
    NotifierProvider<SelectedUserIdNotifier, int?>(SelectedUserIdNotifier.new);

/// Selected user details (null if none selected)
final selectedUserProvider = FutureProvider<UserDto?>((ref) async {
  final id = ref.watch(selectedUserIdProvider);
  if (id == null) return null;
  final api = ref.read(userApiProvider);
  return api.getById(id);
});

/// Simple mutation helpers (call from UI):
class UserActions {
  final Ref ref;
  UserActions(this.ref);

  Future<UserDto> create(UserDto dto) async {
    final api = ref.read(userApiProvider);
    final created = await api.create(dto);
    // refresh list after create
    ref.invalidate(usersProvider);
    return created;
  }

  Future<UserDto> update(UserDto dto) async {
    final api = ref.read(userApiProvider);
    final updated = await api.update(dto);
    // refresh list and selected
    ref.invalidate(usersProvider);
    ref.invalidate(selectedUserProvider);
    return updated;
  }

  Future<void> delete(int id) async {
    final api = ref.read(userApiProvider);
    await api.delete(id);
    // reset selection if we deleted the selected user
    final selected = ref.read(selectedUserIdProvider);
    if (selected == id) {
      ref.read(selectedUserIdProvider.notifier).clear();
    }
    // refresh list
    ref.invalidate(usersProvider);
  }

  Future<({double lat, double lon})?> geocode(String query) async {
    final api = ref.read(userApiProvider);
    return api.geocode(query);
  }
}

/// Provider for actions so you can do: ref.read(userActionsProvider).create(...)
final userActionsProvider = Provider<UserActions>((ref) => UserActions(ref));
