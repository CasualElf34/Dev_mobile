import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/annonce_service.dart';
import '../services/auth_service.dart';
import '../widgets/annonce_card.dart';
import '../theme/app_colors.dart';
import 'detail_annonce_screen.dart';
import 'create_annonce_screen.dart';

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
      body: RefreshIndicator(
        onRefresh: annonceService.fetchAnnonces,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 140.0,
              backgroundColor: AppColors.background,
              title: const Text('LECOIN AUTO', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              centerTitle: true,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                title: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Que recherches-tu ?',
                      hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.normal),
                      prefixIcon: Icon(Icons.search, color: AppColors.primary, size: 20),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(top: 10),
                    ),
                  ),
                ),
                background: Container(color: AppColors.background),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: AppColors.textPrimary),
                  onPressed: () => context.read<AuthService>().logout(),
                )
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ANNONCES PAR PERTINENCE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.textPrimary.withOpacity(0.5)),
                  ],
                ),
              ),
            ),
            annonceService.isLoading
                ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
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
                        childCount: annonceService.annonces.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
