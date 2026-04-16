import 'my_annonces_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final currentUserId = authService.userId;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: const Text('Mon Profil', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<UserModel?>(
        future: currentUserId != null ? authService.getUserById(currentUserId) : null,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          final name = user?.displayName ?? 'Utilisateur';
          final photoUrl = user?.photoUrl;
          final rating = user?.rating ?? 0.0;
          final reviews = user?.reviewsCount ?? 0;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // En-tête Profil
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Édition du profil à venir")),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.primary,
                          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                          child: photoUrl == null ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 8),
                              RatingWidget(rating: rating, reviewsCount: reviews),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Porte-monnaie
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [AppColors.cardColor, AppColors.cardColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Porte-monnaie',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '0,00 €',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: AppColors.primary),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Solde disponible',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Activités
              const Text(
                'Mes activités',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              _buildActivityCard(
                icon: Icons.list_alt,
                title: 'Annonces',
                subtitle: 'Gérer mes annonces déposées',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyAnnoncesScreen()));
                },
              ),
              const SizedBox(height: 12),
              _buildActivityCard(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Transactions',
                subtitle: 'Suivre mes dons et paiements',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Historique des transactions à venir")),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Paramètres
              const Text(
                'Paramètres',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              _buildActivityCard(
                icon: Icons.settings_outlined,
                title: 'Préférences',
                subtitle: 'Notifications, compte, sécurité',
                onTap: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Paramètres à venir")),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildActivityCard(
                icon: Icons.logout,
                title: 'Déconnexion',
                subtitle: 'Quitter l\'application',
                onTap: () => authService.logout(),
                iconColor: Colors.redAccent,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor ?? AppColors.textPrimary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap ?? () {},
      ),
    );
  }
}
