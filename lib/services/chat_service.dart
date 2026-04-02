import 'package:flutter/material.dart';
import '../models/message_model.dart';

class ChatService extends ChangeNotifier {
  final List<MessageModel> _messages = [];

  List<MessageModel> get messages => _messages;

  // Charger les messages d'une conversation (Mock)
  Future<void> fetchMessages(String receiverId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _messages.clear();
    // Messages pour la démo
    _messages.addAll([
      MessageModel(
        id: 'm1',
        senderId: receiverId,
        receiverId: 'mock_user_123',
        content: 'Bonjour, je peux t\'aider avec ta panne !',
        sentAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ]);
    notifyListeners();
  }

  // Envoyer un message (Mock)
  Future<void> sendMessage(String text, String receiverId) async {
    final msg = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'mock_user_123',
      receiverId: receiverId,
      content: text,
      sentAt: DateTime.now(),
    );
    _messages.add(msg);
    notifyListeners();

    // Simulation d'une réponse de l'autre personne
    await Future.delayed(const Duration(seconds: 2));
    _messages.add(
      MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString() + "_reply",
        senderId: receiverId,
        receiverId: 'mock_user_123',
        content: 'C\'est noté. J\'arrive dans 10 minutes !',
        sentAt: DateTime.now(),
      )
    );
    notifyListeners();
  }
}
