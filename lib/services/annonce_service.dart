import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/annonce_model.dart';

class AnnonceService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<AnnonceModel> _annonces = [];
  bool _isLoading = false;

  List<AnnonceModel> get annonces => _annonces;
  bool get isLoading => _isLoading;

  // Stream des annonces en temps réel
  Stream<List<AnnonceModel>> getAnnoncesStream({String? authorId}) {
    Query query = _firestore.collection('annonces').orderBy('createdAt', descending: true);
    
    if (authorId != null) {
      query = query.where('authorId', isEqualTo: authorId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AnnonceModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Récupérer les annonces une seule fois (optionnel avec le stream)
  Future<void> fetchAnnonces() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('annonces')
          .orderBy('createdAt', descending: true)
          .get();
      _annonces.clear();
      for (var doc in snapshot.docs) {
        _annonces.add(AnnonceModel.fromJson(doc.data() as Map<String, dynamic>, doc.id));
      }
    } catch (e) {
      debugPrint('Error fetching annonces: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  // Uploader des images et retourner leurs URLs
  Future<List<String>> uploadImages(List<File> files) async {
    List<String> urls = [];
    for (var file in files) {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      Reference ref = _storage.ref().child('annonces_photos').child(fileName);
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String url = await snapshot.ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  // Publier une annonce dans Firestore
  Future<void> createAnnonce(AnnonceModel annonce, List<File> photos) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Upload des photos
      List<String> photosUrl = await uploadImages(photos);

      // 2. Création de l'annonce avec les vraies URLs et l'ID de l'utilisateur actuel
      final userId = _auth.currentUser?.uid ?? 'guest_user';
      final docRef = _firestore.collection('annonces').doc();
      
      final finalAnnonce = AnnonceModel(
        id: docRef.id,
        authorId: userId,
        title: annonce.title,
        description: annonce.description,
        category: annonce.category,
        photosUrl: photosUrl,
        latitude: annonce.latitude,
        longitude: annonce.longitude,
        createdAt: DateTime.now(),
        suggestedPrice: annonce.suggestedPrice,
      );

      await docRef.set(finalAnnonce.toJson());
      
      // Mise à jour locale
      _annonces.insert(0, finalAnnonce);
    } catch (e) {
      debugPrint('Error creating annonce: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
