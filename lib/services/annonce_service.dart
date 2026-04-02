import 'package:flutter/material.dart';
import '../models/annonce_model.dart';
import '../models/user_model.dart';

class AnnonceService extends ChangeNotifier {
  final List<AnnonceModel> _annonces = [];
  bool _isLoading = false;

  List<AnnonceModel> get annonces => _annonces;
  bool get isLoading => _isLoading;

  // Récupérer les annonces (Mock)
  Future<void> fetchAnnonces() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Simulation réseau

    if (_annonces.isEmpty) {
      _annonces.addAll([
        AnnonceModel(
          id: '1',
          authorId: 'mock_user_2',
          title: 'Panne de batterie sur Clio 4',
          description: 'Je n\'arrive plus à démarrer ma voiture. J\'aurais besoin que quelqu\'un vienne avec des pinces.',
          category: AnnonceCategory.panne,
          photosUrl: [],
          latitude: 48.8566,
          longitude: 2.3522,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          suggestedPrice: 15.0,
        ),
        AnnonceModel(
          id: '2',
          authorId: 'mock_user_3',
          title: 'Recherche plaquettes de frein',
          description: 'Bonjour, je cherche des plaquettes de frein avant pour Peugeot 308 (modèle 2018).',
          category: AnnonceCategory.piece,
          photosUrl: [],
          latitude: 48.8606,
          longitude: 2.3322,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ]);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Publier une annonce
  Future<void> createAnnonce(AnnonceModel annonce) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Simuler l'upload

    _annonces.insert(0, annonce);

    _isLoading = false;
    notifyListeners();
  }
}
