import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/annonce_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/rating_widget.dart';
import 'chat_screen.dart';

class DetailAnnonceScreen extends StatelessWidget {
  final AnnonceModel annonce;

  const DetailAnnonceScreen({super.key, required this.annonce});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Images Carousel / Horizontal list
            if (annonce.photosUrl.isEmpty)
              Container(
                height: 250,
                width: double.infinity,
                color: Colors.grey[800],
                child: const Center(
                  child: Icon(Icons.car_crash, size: 80, color: AppColors.primary),
                ),
              )
            else
              SizedBox(
                height: 250,
                child: PageView.builder(
                  itemCount: annonce.photosUrl.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      annonce.photosUrl[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.error, color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          annonce.category.toString().split('.').last.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (annonce.suggestedPrice != null)
                        Text(
                          '${annonce.suggestedPrice?.toStringAsFixed(0)} €',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    annonce.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<UserModel?>(
                    future: authService.getUserById(annonce.authorId),
                    builder: (context, snapshot) {
                      final user = snapshot.data;
                      return Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primary,
                            backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                            child: user?.photoUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.displayName ?? 'Chargement...',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              RatingWidget(
                                rating: user?.rating ?? 0.0,
                                reviewsCount: user?.reviewsCount ?? 0,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    annonce.description,
                    style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: CustomButton(
                  text: 'Tchat',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          otherUserId: annonce.authorId,
                          annonceId: annonce.id,
                          annonceTitle: annonce.title,
                        ),
                      ),
                    );
                  },
                  isSecondary: true,
                  icon: Icons.chat_bubble_outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: CustomButton(
                  text: 'Proposer mon aide',
                  onPressed: () async {
                    final chatService = context.read<ChatService>();
                    await chatService.sendMessage(
                      "Bonjour ! Je souhaite vous proposer mon aide pour votre annonce : ${annonce.title}", 
                      annonce.authorId,
                      annonce.id,
                      annonceTitle: annonce.title,
                    );
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            otherUserId: annonce.authorId,
                            annonceId: annonce.id,
                            annonceTitle: annonce.title,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
