import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  String? get userId => currentUser?.uid;

  AuthService() {
    _auth.authStateChanges().listen((user) {
      notifyListeners();
    });
  }

  // Connexion
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint('Error login: $e');
      rethrow;
    }
  }

  // Inscription
  Future<void> register(String email, String password, String displayName) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Création du document utilisateur dans Firestore
      if (credential.user != null) {
        UserModel newUser = UserModel(
          id: credential.user!.uid,
          email: email,
          displayName: displayName,
          createdAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(newUser.id).set(newUser.toJson());
      }
    } catch (e) {
      debugPrint('Error register: $e');
      rethrow;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Récupérer les infos d'un utilisateur
  Future<UserModel?> getUserById(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!, doc.id);
      }
    } catch (e) {
      debugPrint('Error getting user by id: $e');
    }
    return null;
  }
}
