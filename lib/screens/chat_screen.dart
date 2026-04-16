import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../theme/app_colors.dart';
import '../models/message_model.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String annonceId;
  final String? annonceTitle;

  const ChatScreen({
    super.key, 
    required this.otherUserId, 
    required this.annonceId,
    this.annonceTitle,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';

  void _send() {
    if (_messageController.text.trim().isNotEmpty) {
      context.read<ChatService>().sendMessage(
        _messageController.text.trim(), 
        widget.otherUserId,
        widget.annonceId,
        annonceTitle: widget.annonceTitle,
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatService = context.read<ChatService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Messagerie', 
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)
            ),
            if (widget.annonceTitle != null)
              Text(
                widget.annonceTitle!,
                style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: chatService.getMessages(widget.otherUserId, widget.annonceId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        const Text(
                          'Dites bonjour !',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == _currentUserId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: isMe ? const LinearGradient(
                                colors: [AppColors.primary, Color(0xFFB089FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ) : null,
                              color: isMe ? null : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft: Radius.circular(isMe ? 20 : 4),
                                bottomRight: Radius.circular(isMe ? 4 : 20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              msg.content,
                              style: TextStyle(
                                color: isMe ? Colors.white : AppColors.textPrimary,
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${msg.sentAt.hour}:${msg.sentAt.minute.toString().padLeft(2, '0')}",
                            style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 10),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Barre de saisie style "iOS"
          Container(
            padding: const EdgeInsets.all(16).copyWith(bottom: 16 + MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Tapez votre message...',
                        hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxCircle(),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
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
