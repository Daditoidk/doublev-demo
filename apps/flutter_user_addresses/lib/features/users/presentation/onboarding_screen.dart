import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_user_addresses/core/l10n/app_localizations.dart';
import 'package:flutter_user_addresses/features/users/presentation/widgets/address_form_widget.dart';
import '../../users/user_models.dart';
import '../../users/user_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  DateTime? _dob;

  // Lista de direcciones que el usuario está agregando
  List<AddressFormData> _addresses = [];

  bool _busy = false;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    // Limpiar controllers de direcciones
    for (var addr in _addresses) {
      addr.dispose();
    }
    super.dispose();
  }

  void _addAddress() {
    setState(() {
      _addresses.add(AddressFormData());
    });
  }

  void _removeAddress(int index) {
    setState(() {
      final addr = _addresses.removeAt(index);
      addr.dispose();
    });
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Validar que al menos tenga una dirección
    if (_addresses.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.mustAddAtLeastOneAddress)));
      return;
    }

    setState(() => _busy = true);

    try {
      // Geocodificar todas las direcciones primero
      final addressDtos = <AddressDto>[];

      for (var i = 0; i < _addresses.length; i++) {
        final addr = _addresses[i];

        // Validar campos requeridos
        if (addr.line1.text.trim().isEmpty ||
            addr.countryCode == null ||
            addr.departmentCode == null ||
            addr.municipalityCode == null) {
          throw Exception(l10n.addressHasIncompleteFields(i + 1));
        }

        addressDtos.add(
          AddressDto(
            line1: addr.line1.text.trim(),
            line2: addr.line2.text.trim().isEmpty
                ? null
                : addr.line2.text.trim(),
            countryCode: addr.countryCode,
            departmentCode: addr.departmentCode,
            municipalityCode: addr.municipalityCode,
            latitude: null,
            longitude: null,
          ),
        );
      }

      // Crear usuario con todas las direcciones
      final dto = UserDto(
        firstName: _first.text.trim(),
        lastName: _last.text.trim(),
        birthDate: _dob,
        addresses: addressDtos,
      );

      final created = await ref.read(userActionsProvider).create(dto);
      ref.read(selectedUserIdProvider.notifier).set(created.id);

      print('✅ Usuario creado: id=${created.id}');
      print(
        '✅ Direcciones con coordenadas: ${created.addresses.map((a) => "(${a.latitude}, ${a.longitude})").join(", ")}',
      );

      if (mounted) {
        // Navegar al mapa (pushReplacement para no poder volver)
        Navigator.of(context).pushReplacementNamed('/map');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.welcomeUserSuccess(created.firstName)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AbsorbPointer(
      absorbing: _busy,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.createProfileTitle), centerTitle: true),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Información personal
              Text(
                l10n.personalInformation,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _first,
                decoration: InputDecoration(
                  labelText: l10n.firstName,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _last,
                decoration: InputDecoration(
                  labelText: l10n.lastName,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
              ),
              const SizedBox(height: 16),

              // Fecha de nacimiento
              InkWell(
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
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.birthDate,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _dob == null
                        ? l10n.selectDate
                        : _dob!.toIso8601String().split("T").first,
                  ),
                ),
              ),

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),

              // Sección de direcciones/propiedades
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.yourProperties,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _addAddress,
                    icon: const Icon(Icons.add_home),
                    label: Text(l10n.add),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Lista de direcciones
              if (_addresses.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.home_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.noPropertiesYet,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.addPropertyToContinue,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...List.generate(_addresses.length, (index) {
                  return AddressFormWidget(
                    key: ValueKey(_addresses[index]),
                    index: index,
                    data: _addresses[index],
                    onRemove: () => _removeAddress(index),
                  );
                }),

              const SizedBox(height: 32),

              // Botón crear
              FilledButton(
                onPressed: _busy ? null : _create,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        l10n.createUserAndContinue,
                        style: const TextStyle(fontSize: 16),
                      ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
