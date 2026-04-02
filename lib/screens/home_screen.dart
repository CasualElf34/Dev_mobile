import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/annonce_service.dart';
import '../services/auth_service.dart';
import '../widgets/annonce_card.dart';
import '../theme/app_colors.dart';
import 'detail_annonce_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Charger de fausses annonces au démarrage
    Future.microtask(() => context.read<AnnonceService>().fetchAnnonces());
  }

  @override
  Widget build(BuildContext context) {
    final annonceService = context.watch<AnnonceService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('LeCoinAuto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthService>().logout();
            },
          )
        ],
      ),
      body: annonceService.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: annonceService.fetchAnnonces,
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: annonceService.annonces.length,
                itemBuilder: (context, index) {
                  return AnnonceCard(
                    annonce: annonceService.annonces[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailAnnonceScreen(
                            annonce: annonceService.annonces[index],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Créer une annonce
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
