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

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Erreur Inbox : ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
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
                annonceId: conv['annonceId'] ?? '',
                annonceTitle: conv['annonceTitle'],
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
  final String annonceId;
  final String? annonceTitle;

  const _ConversationTile({
    required this.otherUserId,
    required this.lastMessage,
    required this.chatId,
    required this.annonceId,
    this.annonceTitle,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                backgroundColor: AppColors.background,
                child: photoUrl == null ? const Icon(Icons.person, color: AppColors.textSecondary, size: 28) : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          title: Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (annonceTitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 2),
                  child: Text(
                    annonceTitle!,
                    style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Text(
                lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  otherUserId: otherUserId,
                  annonceId: annonceId,
                  annonceTitle: annonceTitle,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
