import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/message_model.dart';

class ChatService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtenir l'ID unique de la conversation entre deux utilisateurs
  String getChatId(String user1, String user2) {
    List<String> ids = [user1, user2];
    ids.sort(); // Trier pour que l'ID soit le même peu importe qui commence
    return ids.join('_');
  }

  // Stream des messages en temps réel
  Stream<List<MessageModel>> getMessages(String otherUserId) {
    final currentUserId = _auth.currentUser?.uid ?? 'guest_user';
    final chatId = getChatId(currentUserId, otherUserId);

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
  Future<void> sendMessage(String text, String receiverId) async {
    final currentUserId = _auth.currentUser?.uid ?? 'guest_user';
    final chatId = getChatId(currentUserId, receiverId);

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
    }, SetOptions(merge: true));
  }

  // Stream des conversations de l'utilisateur
  Stream<List<Map<String, dynamic>>> getConversations() {
    final currentUserId = _auth.currentUser?.uid ?? 'guest_user';

    return _firestore
        .collection('chats')
        .where('users', arrayContains: currentUserId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}
