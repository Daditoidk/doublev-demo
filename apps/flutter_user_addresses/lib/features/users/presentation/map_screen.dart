import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter_user_addresses/core/l10n/app_localizations.dart';
import 'package:flutter_user_addresses/features/users/presentation/addres_add_screen.dart';
import 'package:flutter_user_addresses/features/users/presentation/profile_screen.dart';
import 'package:flutter_user_addresses/features/users/user_provider.dart';

import '../../users/user_models.dart';

class UserMapScreen extends ConsumerStatefulWidget {
  const UserMapScreen({super.key});

  @override
  ConsumerState<UserMapScreen> createState() => _UserMapScreenState();
}

class _UserMapScreenState extends ConsumerState<UserMapScreen> {
  final _map = MapController();
  LatLng? _myLatLng;

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

  Future<void> _centerOnMarkers(List<Marker> markers) async {
    if (markers.isEmpty) {
      // fallback: Bogotá
      _map.move(const LatLng(4.7110, -74.0721), 12);
      return;
    }
    // Fit bounds
    final latitudes = markers.map((m) => m.point.latitude).toList();
    final longitudes = markers.map((m) => m.point.longitude).toList();
    final sw = LatLng(
      latitudes.reduce((a, b) => a < b ? a : b),
      longitudes.reduce((a, b) => a < b ? a : b),
    );
    final ne = LatLng(
      latitudes.reduce((a, b) => a > b ? a : b),
      longitudes.reduce((a, b) => a > b ? a : b),
    );
    final bounds = LatLngBounds(sw, ne);
    // padding: left, top, right, bottom
    _map.fitBounds(
      bounds,
      options: const FitBoundsOptions(padding: EdgeInsets.all(48)),
    );
  }

  Future<void> _goToMyLocation(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever ||
        perm == LocationPermission.denied) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        this.context,
      ).showSnackBar(SnackBar(content: Text(l10n.locationPermissionDenied)));
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );
      setState(() {
        _myLatLng = LatLng(pos.latitude, pos.longitude);
      });
      _map.move(_myLatLng!, 12);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        this.context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorWithMessage(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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

          // Build marker list with optional "my location"
          final allMarkers = [
            ...markers,
            if (_myLatLng != null)
              Marker(
                width: 36,
                height: 36,
                point: _myLatLng!,
                child: const Icon(
                  Icons.my_location,
                  size: 28,
                  color: Colors.blue,
                ),
              ),
          ];

          return Stack(
            children: [
              FlutterMap(
                mapController: _map,
                options: MapOptions(initialCenter: center, initialZoom: 12),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'flutter_user_addresses',
                    tileProvider: NetworkTileProvider(
                      headers: {
                        'User-Agent': 'UserAddressesDemo/1.0 (cam@dev.com)',
                        'Referer': 'http://localhost',
                      },
                    ),
                  ),
                  MarkerLayer(markers: allMarkers),
                ],
              ),
              // top-right mini controls
              Positioned(
                right: 12,
                top: 12,
                child: Column(
                  children: [
                    Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: IconButton(
                        tooltip:
                            l10n.centerMarkers, // e.g. 'Centrar marcadores'
                        icon: const Icon(Icons.center_focus_strong),
                        onPressed: () => _centerOnMarkers(markers),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: IconButton(
                        tooltip: l10n.myLocation, // e.g. 'Mi ubicación'
                        icon: const Icon(Icons.my_location),
                        onPressed: () => _goToMyLocation(context),
                      ),
                    ),
                  ],
                ),
              ),
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
