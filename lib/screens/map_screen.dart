import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/annonce_service.dart';
import '../services/location_service.dart';
import '../theme/app_colors.dart';
import 'detail_annonce_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  static const LatLng _defaultCenter = LatLng(48.8566, 2.3522); // Paris

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AnnonceService>().fetchAnnonces();
      _centerOnUser();
    });
  }

  Future<void> _centerOnUser() async {
    final locationService = context.read<LocationService>();
    await locationService.getCurrentPosition();
    if (locationService.currentPosition != null) {
      _mapController.move(
        LatLng(locationService.currentPosition!.latitude, locationService.currentPosition!.longitude),
        13.0,
      );
    }
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
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _defaultCenter,
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
                    radius: 2000, 
                  );
                }).toList(),
              ),
              MarkerLayer(
                markers: annonces.map((annonce) {
                  return Marker(
                    point: LatLng(annonce.latitude, annonce.longitude),
                    width: 80,
                    height: 80,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailAnnonceScreen(annonce: annonce),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '${annonce.suggestedPrice?.toStringAsFixed(0) ?? "?"}€',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        ],
                      ),
                    ),
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
              onPressed: _centerOnUser,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
