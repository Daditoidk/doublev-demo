import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_user_addresses/core/l10n/app_localizations.dart';
import 'package:flutter_user_addresses/features/users/presentation/addres_add_screen.dart';
import 'package:flutter_user_addresses/features/users/presentation/profile_screen.dart';
import 'package:flutter_user_addresses/features/users/user_provider.dart';
import 'package:latlong2/latlong.dart';

import '../../users/user_models.dart';

class UserMapScreen extends ConsumerWidget {
  const UserMapScreen({super.key});

  List<Marker> _markersForUser(UserDto u) {
    final markers = <Marker>[];
    for (final a in u.addresses) {
      if (a.latitude != null && a.longitude != null) {
        markers.add(
          Marker(
            width: 40,
            height: 40,
            point: LatLng(a.latitude!, a.longitude!),
            child: Tooltip(
              message: '${u.firstName} ${u.lastName}\n${a.line1 ?? ''}',
              child: const Icon(Icons.location_pin, size: 36),
            ),
          ),
        );
      }
    }
    return markers;
  }

  Future<void> _addProperty(
    BuildContext context,
    WidgetRef ref,
    UserDto user,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final addrCtrl = TextEditingController(text: l10n.defaultAddressExample);
    final addressText = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.addProperty),
        content: TextField(
          controller: addrCtrl,
          decoration: InputDecoration(labelText: l10n.addressDialogLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, addrCtrl.text.trim()),
            child: Text(l10n.geocode),
          ),
        ],
      ),
    );

    if (addressText == null || addressText.isEmpty) return;

    final actions = ref.read(userActionsProvider);

    // Geocode first
    final geo = await actions.geocode(addressText);
    if (geo == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.geocodeFailed)));
      }
      return;
    }

    // Build new Address (for demo, default CO/CUN/BOG — adjust with catalog dropdowns if you want)
    final newAddress = AddressDto(
      line1: addressText,
      countryCode: 'CO',
      departmentCode: 'CUN',
      municipalityCode: 'BOG',
      latitude: geo.lat,
      longitude: geo.lon,
    );

    // Update user with the extra address
    final updated = UserDto(
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      birthDate: user.birthDate,
      addresses: [...user.addresses, newAddress],
    );

    await actions.update(updated);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.propertyAdded)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // we only show the selected user (set in Onboarding or Profile)
    final selectedUser = ref.watch(selectedUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.goToProfile,
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UserProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: selectedUser.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorWithMessage(e))),
        data: (u) {
          if (u == null) {
            return Center(
              child: Text(l10n.noUserSelectedHelp, textAlign: TextAlign.center),
            );
          }

          final markers = _markersForUser(u);
          // Default center = Bogotá; if user has markers, center on the first one
          LatLng center = const LatLng(4.7110, -74.0721);
          if (markers.isNotEmpty) center = markers.first.point;

          return FlutterMap(
            options: MapOptions(initialCenter: center, initialZoom: 12),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'flutter_user_addresses',
                tileProvider: NetworkTileProvider(
                  headers: {
                    'User-Agent': 'UserAddressesDemo/1.0 (cam@dev.com)',
                    'Referer': 'http://localhost',
                  },
                ),
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
      floatingActionButton: selectedUser.maybeWhen(
        data: (u) => u == null
            ? null
            : FloatingActionButton.extended(
                icon: const Icon(Icons.add_location_alt),
                label: Text(l10n.addProperty),
                onPressed: () async {
                  final added = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => const AddressAddScreen()),
                  );
                  if (added == true) {
                    // Refresh selected user so new marker appears
                    ref.invalidate(selectedUserProvider);
                  }
                },
              ),
        orElse: () => null,
      ),
    );
  }
}
