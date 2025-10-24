import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_user_addresses/core/l10n/app_localizations.dart';
import 'package:flutter_user_addresses/features/catalog/catalog_provider.dart';

class AddressFormData {
  final line1 = TextEditingController();
  final line2 = TextEditingController();
  String? countryCode;
  String? countryName;
  String? departmentCode;
  String? departmentName;
  String? municipalityCode;
  String? municipalityName;

  void dispose() {
    line1.dispose();
    line2.dispose();
  }
}

class AddressFormWidget extends ConsumerStatefulWidget {
  final int index;
  final AddressFormData data;
  final VoidCallback onRemove;

  const AddressFormWidget({
    super.key,
    required this.index,
    required this.data,
    required this.onRemove,
  });

  @override
  ConsumerState<AddressFormWidget> createState() => _AddressFormWidgetState();
}

class _AddressFormWidgetState extends ConsumerState<AddressFormWidget> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final countriesAsync = ref.watch(countriesProvider);
    final departmentsAsync = widget.data.countryCode != null
        ? ref.watch(departmentsProvider(widget.data.countryCode!))
        : null;
    final municipalitiesAsync = widget.data.departmentCode != null
        ? ref.watch(municipalitiesProvider(widget.data.departmentCode!))
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.propertyNumber(widget.index + 1),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dirección línea 1
            TextFormField(
              controller: widget.data.line1,
              decoration: InputDecoration(
                labelText: '${l10n.address} *',
                hintText: l10n.addressLine1Hint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.home),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
            ),
            const SizedBox(height: 12),

            // Dirección línea 2
            TextFormField(
              controller: widget.data.line2,
              decoration: InputDecoration(
                labelText: l10n.complementOptional,
                hintText: l10n.addressLine2Hint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.apartment),
              ),
            ),
            const SizedBox(height: 12),

            // País dropdown
            countriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(l10n.errorLoadingCountries(e)),
              data: (countries) {
                return DropdownButtonFormField<String>(
                  value: widget.data.countryCode,
                  decoration: InputDecoration(
                    labelText: '${l10n.country} *',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.public),
                  ),
                  items: countries.map((c) {
                    return DropdownMenuItem(value: c.code, child: Text(c.name));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      widget.data.countryCode = value;
                      widget.data.countryName = value == null
                          ? null
                          : countries.firstWhere((c) => c.code == value).name;
                      widget.data.departmentCode = null;
                      widget.data.departmentName = null;
                      widget.data.municipalityCode = null;
                      widget.data.municipalityName = null;
                    });
                  },
                  validator: (v) => v == null ? l10n.requiredField : null,
                );
              },
            ),
            const SizedBox(height: 12),

            // Departamento dropdown
            if (widget.data.countryCode != null)
              departmentsAsync?.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text(l10n.errorLoadingDepartments(e)),
                    data: (departments) {
                      return DropdownButtonFormField<String>(
                        value: widget.data.departmentCode,
                        decoration: InputDecoration(
                          labelText: '${l10n.department} *',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.location_city),
                        ),
                        items: departments.map((d) {
                          return DropdownMenuItem(
                            value: d.code,
                            child: Text(d.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            widget.data.departmentCode = value;
                            widget.data.departmentName = value == null
                                ? null
                                : departments
                                      .firstWhere((d) => d.code == value)
                                      .name;
                            widget.data.municipalityCode = null;
                            widget.data.municipalityName = null;
                          });
                        },
                        validator: (v) => v == null ? l10n.requiredField : null,
                      );
                    },
                  ) ??
                  const SizedBox.shrink(),
            if (widget.data.countryCode != null) const SizedBox(height: 12),

            // Municipio dropdown
            if (widget.data.departmentCode != null)
              municipalitiesAsync?.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text(l10n.errorLoadingMunicipalities(e)),
                    data: (municipalities) {
                      return DropdownButtonFormField<String>(
                        value: widget.data.municipalityCode,
                        decoration: InputDecoration(
                          labelText: '${l10n.municipality} *',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.place),
                        ),
                        items: municipalities.map((m) {
                          return DropdownMenuItem(
                            value: m.code,
                            child: Text(m.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            widget.data.municipalityCode = value;
                            widget.data.municipalityName = value == null
                                ? null
                                : municipalities
                                      .firstWhere((m) => m.code == value)
                                      .name;
                          });
                        },
                        validator: (v) => v == null ? l10n.requiredField : null,
                      );
                    },
                  ) ??
                  const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
