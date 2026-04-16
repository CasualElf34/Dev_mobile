import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/message_model.dart';

class ChatService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtenir l'ID unique de la conversation entre deux utilisateurs POUR UNE ANNONCE
  String getChatId(String user1, String user2, String annonceId) {
    List<String> ids = [user1, user2];
    ids.sort();
    return '${ids.join('_')}_$annonceId';
  }

  // Stream des messages en temps réel
  Stream<List<MessageModel>> getMessages(String otherUserId, String annonceId) {
    final currentUserId = _auth.currentUser?.uid ?? 'guest_user';
    final chatId = getChatId(currentUserId, otherUserId, annonceId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  // Envoyer un message
  Future<void> sendMessage(String text, String receiverId, String annonceId, {String? annonceTitle}) async {
    final currentUserId = _auth.currentUser?.uid ?? 'guest_user';
    final chatId = getChatId(currentUserId, receiverId, annonceId);

    final docRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    final message = MessageModel(
      id: docRef.id,
      senderId: currentUserId,
      receiverId: receiverId,
      content: text,
      sentAt: DateTime.now(),
    );

    await docRef.set(message.toJson());

    // Mettre à jour le dernier message de la conversation pour l'inbox
    await _firestore.collection('chats').doc(chatId).set({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'users': [currentUserId, receiverId],
      'annonceId': annonceId,
      if (annonceTitle != null) 'annonceTitle': annonceTitle,
    }, SetOptions(merge: true));
  }

  // Stream des conversations de l'utilisateur
  Stream<List<Map<String, dynamic>>> getConversations() {
    final currentUserId = _auth.currentUser?.uid ?? 'guest_user';

    // On retire le orderBy pour éviter de forcer l'utilisateur à créer un index composite
    return _firestore
        .collection('chats')
        .where('users', arrayContains: currentUserId)
        .snapshots()
        .map((snapshot) {
      final conversations = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Tri local par date du dernier message (décroissant)
      conversations.sort((a, b) {
        final dateA = _parseDateTime(a['lastMessageAt']);
        final dateB = _parseDateTime(b['lastMessageAt']);
        return dateB.compareTo(dateA);
      });

      return conversations;
    });
  }

  // Helper pour parser les dates Firestore (Timestamp ou String)
  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    if (value is DateTime) return value;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
