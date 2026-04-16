import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  String? _currentAddress;

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;

  // Demander la localisation
  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false; // Les services de localisation sont désactivés
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<void> getCurrentPosition() async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) return;

    try {
      // 1. Tenter d'obtenir la dernière position pour un résultat immédiat
      Position? position = await Geolocator.getLastKnownPosition();
      
      // 2. Sinon, demander la position avec un délai max de 5s pour éviter le plantage
      position ??= await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      );

      _currentPosition = position;
      notifyListeners(); // Rafraîchir l'écran tout de suite
      
      // 3. Obtenir l'adresse exacte (avec un timeout car c'est cette fonction qui fait planter Android souvent)
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude)
          .timeout(const Duration(seconds: 5));
          
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _currentAddress = '${place.street ?? ''}, ${place.postalCode ?? ''} ${place.locality ?? ''}'.trim();
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur localisation: $e");
      // Si seule la transformation en adresse (Geocoder) plante, on affiche au moins les positions
      if (_currentPosition != null && _currentAddress == null) {
        _currentAddress = 'Lat: ${_currentPosition!.latitude.toStringAsFixed(3)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(3)}';
        notifyListeners();
      }
    }
  }
}
