import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:firebase_storage/firebase_storage.dart';

class StorageService extends ChangeNotifier {
  bool _isUploading = false;
  bool get isUploading => _isUploading;

  // Mock upload d'image
  Future<String?> uploadImage(File imageFile) async {
    _isUploading = true;
    notifyListeners();

    // Simulation de l'envoi cloud
    await Future.delayed(const Duration(seconds: 1));

    _isUploading = false;
    notifyListeners();

    // Retourne une URL factice
    return 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/400/300';
  }
}
