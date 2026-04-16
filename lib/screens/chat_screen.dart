import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../theme/app_colors.dart';
import '../models/message_model.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;

  const ChatScreen({super.key, required this.otherUserId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';

  void _send() {
    if (_messageController.text.trim().isNotEmpty) {
      context.read<ChatService>().sendMessage(_messageController.text.trim(), widget.otherUserId);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatService = context.read<ChatService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messagerie'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: chatService.getMessages(widget.otherUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucun message. Dites bonjour !',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  reverse: true, // Pour voir les derniers messages en bas
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == _currentUserId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.primary : AppColors.cardColor,
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomRight: isMe ? const Radius.circular(0) : null,
                            bottomLeft: !isMe ? const Radius.circular(0) : null,
                          ),
                        ),
                        child: Text(
                          msg.content,
                          style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0).copyWith(bottom: 8 + MediaQuery.of(context).padding.bottom),
            color: AppColors.background,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Votre message...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
