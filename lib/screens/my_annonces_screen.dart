import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/annonce_service.dart';
import '../services/auth_service.dart';
import '../models/annonce_model.dart';
import '../widgets/annonce_card.dart';
import '../theme/app_colors.dart';
import 'detail_annonce_screen.dart';

class MyAnnoncesScreen extends StatelessWidget {
  const MyAnnoncesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final annonceService = context.read<AnnonceService>();
    final userId = context.read<AuthService>().userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Annonces', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: userId == null
          ? const Center(child: Text("Veuillez vous connecter"))
          : StreamBuilder<List<AnnonceModel>>(
              stream: annonceService.getAnnoncesStream(authorId: userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.list_alt, size: 80, color: AppColors.textSecondary.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        const Text("Vous n'avez pas encore posté d'annonce.", style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }

                final annonces = snapshot.data!;

                return GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: annonces.length,
                  itemBuilder: (context, index) {
                    return AnnonceCard(
                      annonce: annonces[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailAnnonceScreen(annonce: annonces[index]),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
