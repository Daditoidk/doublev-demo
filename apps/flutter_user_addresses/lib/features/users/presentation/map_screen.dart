// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class MapScreen extends ConsumerWidget {
//   const MapScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // final properties = ref.watch(propertiesProvider);

//     return Scaffold(
//       body: Stack(
//         children: [
//           FlutterMap(
//             options: MapOptions(
//               initialCenter: LatLng(4.6097, -74.0817),
//               initialZoom: 6.0,
//             ),
//             children: [
//               // Capa de tiles (mapa base)
//               TileLayer(
//                 urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                 userAgentPackageName: 'com.doublevpartners.properties',
//               ),

//               // Capa de markers (propiedades)
//               MarkerLayer(
//                 markers: properties.map((property) {
//                   return Marker(
//                     point: LatLng(
//                       property.latitude ?? 0,
//                       property.longitude ?? 0
//                     ),
//                     width: 60,
//                     height: 60,
//                     child: GestureDetector(
//                       onTap: () => _showPropertyDetail(context, property),
//                       child: Column(
//                         children: [
//                           Icon(
//                             Icons.home_filled,
//                             color: Colors.blue,
//                             size: 40,
//                           ),
//                           Container(
//                             padding: EdgeInsets.all(2),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Text(
//                               property.line1,
//                               style: TextStyle(fontSize: 8),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ],
//           ),

//           // Avatar en esquina
//           Positioned(
//             top: 50,
//             right: 20,
//             child: GestureDetector(
//               onTap: () => Navigator.pushNamed(context, '/profile'),
//               child: CircleAvatar(
//                 radius: 25,
//                 backgroundColor: Colors.white,
//                 child: Icon(Icons.person),
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => Navigator.pushNamed(context, '/add-property'),
//         child: Icon(Icons.add_home),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Map")));
  }
}
