import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_user_addresses/core/l10n/app_localizations.dart';
import 'package:flutter_user_addresses/features/users/presentation/addres_add_screen.dart';
import 'package:flutter_user_addresses/features/users/presentation/address_edit_screen.dart';
import 'package:flutter_user_addresses/features/users/user_provider.dart';

import '../../users/user_models.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() =>
      _UserProfileEditScreenState();
}

class _UserProfileEditScreenState extends ConsumerState<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  DateTime? _dob;
  List<AddressDto> _addresses = [];
  bool _saving = false;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  void _load(UserDto u) {
    _first.text = u.firstName;
    _last.text = u.lastName;
    _dob = u.birthDate;
    _addresses = List<AddressDto>.from(u.addresses);
  }

  Future<void> _save(UserDto u) async {
    final l10n = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final payload = UserDto(
      id: u.id,
      firstName: _first.text.trim(),
      lastName: _last.text.trim(),
      birthDate: _dob,
      // Let server re-geocode any changed addresses (we nullify lat/lon)
      addresses: _addresses
          .map((a) => a.copyWith(latitude: null, longitude: null))
          .toList(),
    );

    try {
      await ref.read(userActionsProvider).update(payload);
      // Refresh selected user
      ref.invalidate(selectedUserProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.profileSaved)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorWithMessage(e))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedUser = ref.watch(selectedUserProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfileTitle)),
      body: selectedUser.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorWithMessage(e))),
        data: (u) {
          if (u == null) {
            return Center(child: Text(l10n.noUserSelected));
          }
          // Initialize form with user data (only once per load)
          if (_first.text.isEmpty && _addresses.isEmpty) _load(u);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _first,
                  decoration: InputDecoration(labelText: l10n.firstName),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.requiredField
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _last,
                  decoration: InputDecoration(labelText: l10n.lastName),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.requiredField
                      : null,
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _dob == null
                        ? l10n.birthDate
                        : '${l10n.birthDate}: ${_dob!.toIso8601String().split("T").first}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      lastDate: DateTime(now.year, now.month, now.day),
                      initialDate: _dob ?? DateTime(2000, 1, 1),
                    );
                    if (picked != null) setState(() => _dob = picked);
                  },
                ),
                const Divider(height: 32),
                Row(
                  children: [
                    Text(
                      l10n.addresses,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.add_location_alt),
                      tooltip: l10n.addAddress,
                      onPressed: () async {
                        final added = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => const AddressAddScreen(),
                          ),
                        );
                        if (added == true) {
                          // reload selected user and local list
                          final refreshed = await ref.read(
                            selectedUserProvider.future,
                          );
                          if (refreshed != null) {
                            setState(
                              () => _addresses = List<AddressDto>.from(
                                refreshed.addresses,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_addresses.isEmpty) Text(l10n.noAddressesYet),
                ..._addresses.asMap().entries.map((e) {
                  final i = e.key;
                  final a = e.value;
                  return Card(
                    child: ListTile(
                      title: Text(a.line1 ?? l10n.addressWithoutLine1),
                      subtitle: Text(
                        '${a.municipalityCode ?? ''} - ${a.departmentCode ?? ''} - ${a.countryCode ?? ''}',
                      ),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              final changed = await Navigator.of(context)
                                  .push<bool>(
                                    MaterialPageRoute(
                                      builder: (_) => AddressEditScreen(
                                        index: i,
                                        initial: a,
                                      ),
                                    ),
                                  );
                              if (changed == true) {
                                // refresh local addresses from server
                                final refreshed = await ref.read(
                                  selectedUserProvider.future,
                                );
                                if (refreshed != null) {
                                  setState(
                                    () => _addresses = List<AddressDto>.from(
                                      refreshed.addresses,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(l10n.deleteAddressTitle),
                                  content: Text(
                                    l10n.confirmDeleteAddress(a.line1 ?? ''),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: Text(l10n.cancel),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text(l10n.delete),
                                    ),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                setState(() => _addresses.removeAt(i));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _saving ? null : () => _save(u),
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(l10n.saveProfile),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
