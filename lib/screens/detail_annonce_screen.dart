import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
import '../models/annonce_model.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/rating_widget.dart';
import 'chat_screen.dart';

class DetailAnnonceScreen extends StatelessWidget {
  final AnnonceModel annonce;

  const DetailAnnonceScreen({super.key, required this.annonce});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder (Carousel in real life)
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[800],
              child: const Center(
                child: Icon(Icons.car_crash, size: 80, color: AppColors.primary),
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
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Utilisateur_123', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          const RatingWidget(rating: 4.8, reviewsCount: 12),
                        ],
                      ),
                    ],
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
                        builder: (_) => ChatScreen(otherUserId: annonce.authorId),
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
                  onPressed: () {
                    // Start payment flow or accepted flow
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
