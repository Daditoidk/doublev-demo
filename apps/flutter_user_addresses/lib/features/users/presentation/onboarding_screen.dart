import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../users/user_models.dart';
import '../../users/user_provider.dart';
import '../../catalog/catalog_provider.dart';

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
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Validar que al menos tenga una dirección
    if (_addresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes agregar al menos una dirección/propiedad'),
        ),
      );
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
          throw Exception('La dirección ${i + 1} tiene campos incompletos');
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

      print('✅ Usuario creado: id=${created.id}');
      print(
        '✅ Direcciones con coordenadas: ${created.addresses.map((a) => "(${a.latitude}, ${a.longitude})").join(", ")}',
      );

      if (mounted) {
        // Navegar al mapa (pushReplacement para no poder volver)
        Navigator.of(context).pushReplacementNamed('/map');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Bienvenido ${created.firstName}! Usuario creado exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _busy,
      child: Scaffold(
        appBar: AppBar(title: const Text('Crear tu Perfil'), centerTitle: true),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Información personal
              Text(
                'Información Personal',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _first,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nombre requerido' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _last,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Apellido requerido'
                    : null,
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
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Nacimiento',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _dob == null
                        ? 'Seleccionar fecha'
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
                    'Tus Propiedades',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _addAddress,
                    icon: const Icon(Icons.add_home),
                    label: const Text('Agregar'),
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
                          'No has agregado propiedades',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Agrega al menos una propiedad para continuar',
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
                    : const Text(
                        'Crear Usuario y Continuar',
                        style: TextStyle(fontSize: 16),
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

// ========== Widget para cada formulario de dirección ==========

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
                  'Propiedad ${widget.index + 1}',
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
              decoration: const InputDecoration(
                labelText: 'Dirección *',
                hintText: 'Ej: Calle 123 #45-67',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Dirección requerida'
                  : null,
            ),
            const SizedBox(height: 12),

            // Dirección línea 2
            TextFormField(
              controller: widget.data.line2,
              decoration: const InputDecoration(
                labelText: 'Complemento (Opcional)',
                hintText: 'Ej: Apto 301, Torre B',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.apartment),
              ),
            ),
            const SizedBox(height: 12),

            // País dropdown
            countriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error cargando países: $e'),
              data: (countries) {
                return DropdownButtonFormField<String>(
                  value: widget.data.countryCode,
                  decoration: const InputDecoration(
                    labelText: 'País *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.public),
                  ),
                  items: countries.map((c) {
                    return DropdownMenuItem(value: c.code, child: Text(c.name));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      widget.data.countryCode = value;
                      widget.data.countryName = countries
                          .firstWhere((c) => c.code == value)
                          .name;
                      widget.data.departmentCode = null;
                      widget.data.departmentName = null;
                      widget.data.municipalityCode = null;
                      widget.data.municipalityName = null;
                    });
                  },
                  validator: (v) => v == null ? 'País requerido' : null,
                );
              },
            ),
            const SizedBox(height: 12),

            // Departamento dropdown
            if (widget.data.countryCode != null)
              departmentsAsync?.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error cargando departamentos: $e'),
                    data: (departments) {
                      return DropdownButtonFormField<String>(
                        value: widget.data.departmentCode,
                        decoration: const InputDecoration(
                          labelText: 'Departamento *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_city),
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
                            widget.data.departmentName = departments
                                .firstWhere((d) => d.code == value)
                                .name;
                            widget.data.municipalityCode = null;
                            widget.data.municipalityName = null;
                          });
                        },
                        validator: (v) =>
                            v == null ? 'Departamento requerido' : null,
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
                    error: (e, _) => Text('Error cargando municipios: $e'),
                    data: (municipalities) {
                      return DropdownButtonFormField<String>(
                        value: widget.data.municipalityCode,
                        decoration: const InputDecoration(
                          labelText: 'Municipio *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.place),
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
                            widget.data.municipalityName = municipalities
                                .firstWhere((m) => m.code == value)
                                .name;
                          });
                        },
                        validator: (v) =>
                            v == null ? 'Municipio requerido' : null,
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
