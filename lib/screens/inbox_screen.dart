import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'chat_screen.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Fausse liste de conversations simulée
    final conversations = [
      {
        'userId': 'mock_user_2',
        'name': 'Jean Dupont',
        'lastMessage': 'J\'arrive dans 10 minutes !',
        'time': '10:05',
        'unread': true,
        'image': 'https://picsum.photos/100'
      },
      {
        'userId': 'mock_user_3',
        'name': 'Garage Martin',
        'lastMessage': 'La pièce de Peugeot 308 est toujours disponible, je vous la mets de côté ?',
        'time': 'Hier',
        'unread': false,
        'image': 'https://picsum.photos/101'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes messages', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_chat_read_outlined, color: AppColors.textPrimary),
            onPressed: () {},
          )
        ],
      ),
      body: conversations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: AppColors.textSecondary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('Aucune conversation', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            )
          : ListView.separated(
              itemCount: conversations.length,
              separatorBuilder: (context, index) => const Divider(color: AppColors.cardColor, height: 1),
              itemBuilder: (context, index) {
                final conv = conversations[index];
                final isUnread = conv['unread'] as bool;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(conv['image'] as String),
                    backgroundColor: AppColors.cardColor,
                  ),
                  title: Text(
                    conv['name'] as String,
                    style: TextStyle(
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      conv['lastMessage'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isUnread ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        conv['time'] as String,
                        style: TextStyle(
                          color: isUnread ? AppColors.primary : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: isUnread ? FontWeight.bold : null,
                        ),
                      ),
                      if (isUnread)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '1',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(otherUserId: conv['userId'] as String),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
