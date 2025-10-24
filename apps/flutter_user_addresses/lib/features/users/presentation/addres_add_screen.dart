import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_user_addresses/core/l10n/app_localizations.dart';
import 'package:flutter_user_addresses/features/users/presentation/widgets/address_form_widget.dart';
import 'package:flutter_user_addresses/features/users/user_provider.dart';

import '../../users/user_models.dart';

class AddressAddScreen extends ConsumerStatefulWidget {
  const AddressAddScreen({super.key});

  @override
  ConsumerState<AddressAddScreen> createState() => _AddressAddScreenState();
}

class _AddressAddScreenState extends ConsumerState<AddressAddScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AddressFormData _form; // created in initState
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _form = AddressFormData()
      ..countryCode = 'CO'
      ..departmentCode = 'CUN'
      ..municipalityCode = 'BOG';
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  AddressDto _toDto() => AddressDto(
    line1: _form.line1.text.trim(),
    line2: _form.line2.text.trim().isEmpty ? null : _form.line2.text.trim(),
    countryCode: _form.countryCode,
    departmentCode: _form.departmentCode,
    municipalityCode: _form.municipalityCode,
    // Server geocodes:
    latitude: null,
    longitude: null,
  );

  Future<void> _save(UserDto user) async {
    final l10n = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final newAddress = _toDto();
    final updated = user.copyWith(addresses: [...user.addresses, newAddress]);

    try {
      await ref.read(userActionsProvider).update(updated);
      if (mounted) Navigator.pop(context, true); // indicate success
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorSaving(e))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedUserAsync = ref.watch(selectedUserProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addAddress)),
      body: selectedUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorWithMessage(e))),
        data: (user) {
          if (user == null) {
            return Center(child: Text(l10n.noUserSelected));
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AddressFormWidget(
                  index: 0,
                  data: _form,
                  onRemove: () {
                    // For add screen, act like "clear"
                    _form.line1.clear();
                    _form.line2.clear();
                    setState(() {
                      _form.countryCode = null;
                      _form.departmentCode = null;
                      _form.municipalityCode = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _saving ? null : () => _save(user),
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(l10n.saveAddress),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
