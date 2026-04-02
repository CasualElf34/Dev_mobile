import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/annonce_service.dart';
import '../theme/app_colors.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Coordonnées par défaut (ex: Paris)
  static const LatLng _initialPosition = LatLng(48.8566, 2.3522);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AnnonceService>().fetchAnnonces());
  }

  @override
  Widget build(BuildContext context) {
    final annonces = context.watch<AnnonceService>().annonces;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte des annonces'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: _initialPosition,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.lecoinauto',
              ),
              CircleLayer(
                circles: annonces.map((annonce) {
                  return CircleMarker(
                    point: LatLng(annonce.latitude, annonce.longitude),
                    color: AppColors.primary.withOpacity(0.3),
                    borderStrokeWidth: 2,
                    borderColor: AppColors.primary,
                    useRadiusInMeter: true,
                    radius: 3000, // Zone d'environ 3 km pour ne pas donner l'adresse exacte
                  );
                }).toList(),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () {
                // Recentrer sur l'utilisateur
              },
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
