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
    // Si on a un authorId, on ne fait pas le orderBy dans Firestore pour éviter l'erreur d'index composite
    Query query = _firestore.collection('annonces');
    
    if (authorId != null) {
      query = query.where('authorId', isEqualTo: authorId);
    } else {
      query = query.orderBy('createdAt', descending: true);
    }

    return query.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return AnnonceModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      
      // Si on a filtré par auteur, on trie manuellement en Dart pour compenser l'absence de orderBy Firestore
      if (authorId != null) {
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      return list;
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
      // Lecture des octets pour éviter les erreurs d'accès au fichier (plus robuste sur émul/windows)
      final bytes = await file.readAsBytes();
      
      // Correction du nom de fichier pour Windows/mobile
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split(RegExp(r'[/\\]')).last}';
      Reference ref = _storage.ref().child('annonces_photos').child(fileName);
      UploadTask uploadTask = ref.putData(bytes);
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
      // 1. Upload des photos (on le rend tolérant pour ne pas bloquer l'annonce)
      List<String> photosUrl = [];
      try {
        photosUrl = await uploadImages(photos);
      } catch (e) {
        debugPrint('Warning: Image upload partially or fully failed: $e');
        // On continue quand même pour ne pas bloquer l'utilisateur
      }

      // 2. Création de l'annonce avec les URLs (peuvent être vides si échec)
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
      
      // Mise à jour locale (si les streams ne sont pas utilisés partout)
      _annonces.insert(0, finalAnnonce);
    } catch (e) {
      debugPrint('Error creating annonce: $e');
      rethrow; // On rethrow seulement si l'écriture Firestore elle-même échoue
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
