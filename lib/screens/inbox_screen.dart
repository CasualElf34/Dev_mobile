import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../models/user_model.dart';
import 'chat_screen.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = context.watch<ChatService>();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes messages', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatService.getConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: AppColors.textSecondary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('Aucune conversation', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          final conversations = snapshot.data!;

          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (context, index) => const Divider(color: AppColors.cardColor, height: 1),
            itemBuilder: (context, index) {
              final conv = conversations[index];
              final List<dynamic> users = conv['users'] ?? [];
              final otherUserId = users.firstWhere((id) => id != currentUserId, orElse: () => '');

              return _ConversationTile(
                otherUserId: otherUserId,
                lastMessage: conv['lastMessage'] ?? '',
                chatId: conv['id'],
              );
            },
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final String otherUserId;
  final String lastMessage;
  final String chatId;

  const _ConversationTile({
    required this.otherUserId,
    required this.lastMessage,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();

    return FutureBuilder<UserModel?>(
      future: authService.getUserById(otherUserId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final name = user?.displayName ?? 'Utilisateur';
        final photoUrl = user?.photoUrl;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            radius: 24,
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            backgroundColor: AppColors.cardColor,
            child: photoUrl == null ? const Icon(Icons.person, color: AppColors.textSecondary) : null,
          ),
          title: Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(otherUserId: otherUserId),
              ),
            );
          },
        );
      },
    );
  }
}
