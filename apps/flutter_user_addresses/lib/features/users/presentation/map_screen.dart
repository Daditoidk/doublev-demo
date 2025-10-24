import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_user_addresses/features/users/user_provider.dart';
import 'package:latlong2/latlong.dart';
import '../../users/user_models.dart';

class UserMapScreen extends ConsumerWidget {
  const UserMapScreen({super.key});

  List<Marker> _buildMarkers(List<UserDto> users) {
    final markers = <Marker>[];
    for (final u in users) {
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
    }
    return markers;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de direcciones')),
      body: users.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          final markers = _buildMarkers(list);
          // Default center = Bogotá
          LatLng center = const LatLng(4.7110, -74.0721);
          if (markers.isNotEmpty) {
            center = markers.first.point;
          }

          return FlutterMap(
            options: MapOptions(initialCenter: center, initialZoom: 12),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.refresh),
        label: const Text('Refrescar'),
        onPressed: () => ref.invalidate(usersProvider),
      ),
    );
  }
}
