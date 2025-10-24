import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_user_addresses/core/l10n/app_localizations.dart';
import 'package:flutter_user_addresses/features/users/presentation/utils/utils.dart';
import 'package:flutter_user_addresses/features/users/presentation/widgets/address_form_widget.dart';
import 'package:flutter_user_addresses/features/users/user_provider.dart';

import '../../users/user_models.dart';

class AddressEditScreen extends ConsumerStatefulWidget {
  final int index; // index in user.addresses
  final AddressDto initial;

  const AddressEditScreen({
    super.key,
    required this.index,
    required this.initial,
  });

  @override
  ConsumerState<AddressEditScreen> createState() => _AddressEditScreenState();
}

class _AddressEditScreenState extends ConsumerState<AddressEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AddressFormData _form;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _form = AddressFormData()
      ..line1.text = widget.initial.line1 ?? ''
      ..line2.text = widget.initial.line2 ?? ''
      ..countryCode = widget.initial.countryCode
      ..departmentCode = widget.initial.departmentCode
      ..municipalityCode = widget.initial.municipalityCode;
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _save(UserDto user) async {
    final l10n = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    // Build the edited address (server will re-geocode)
    final editedAddress = AddressDto(
      line1: _form.line1.text.trim(),
      line2: _form.line2.text.trim().isEmpty ? null : _form.line2.text.trim(),
      countryCode: _form.countryCode,
      departmentCode: _form.departmentCode,
      municipalityCode: _form.municipalityCode,
      latitude: null,
      longitude: null,
    );

    final updatedList = [...user.addresses];
    updatedList[widget.index] = editedAddress;

    try {
      // PUT /users/{id} — server geocodes
      final updatedUser = await ref
          .read(userActionsProvider)
          .update(user.copyWith(addresses: updatedList));

      // refresh caches (Map/Profile)
      ref.invalidate(selectedUserProvider);

      // Toast if the edited address has no coords
      AddressDto? returned;
      if (widget.index >= 0 && widget.index < updatedUser.addresses.length) {
        returned = updatedUser.addresses[widget.index];
      }
      if (returned != null && !hasCoords(returned) && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.addressNoCoords)));
      }

      if (mounted) Navigator.pop(context, true);
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

  Future<void> _delete(UserDto user) async {
    final l10n = AppLocalizations.of(context)!;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAddressTitle),
        content: Text(l10n.confirmDeleteAddress(_form.line1.text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _saving = true);
    try {
      final updated = [...user.addresses]..removeAt(widget.index);
      await ref
          .read(userActionsProvider)
          .update(user.copyWith(addresses: updated));

      // refresh caches (Map/Profile)
      ref.invalidate(selectedUserProvider);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.addressDeleted)));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorDeleting(e))));
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
      appBar: AppBar(title: Text(l10n.editAddressTitle)),
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
                  index: widget.index,
                  data: _form,
                  onRemove: () => _delete(user),
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
                  label: Text(l10n.saveChanges),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
