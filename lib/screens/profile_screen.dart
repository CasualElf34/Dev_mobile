import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/rating_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          onPressed: () {
            // Ouvrir le menu latéral (drawer)
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const TextField(
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Rechercher sur LeCoinAuto',
              hintStyle: TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: 20),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      drawer: const _MockDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // En-tête Profil
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primary,
                        backgroundImage: NetworkImage('https://picsum.photos/200'), // Fausse image de l'utilisateur
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.cardColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(Icons.edit, size: 16, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Maël',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 8),
                        RatingWidget(rating: 5.0, reviewsCount: 18),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
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
          ),
          const SizedBox(height: 12),
          _buildActivityCard(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Transactions',
            subtitle: 'Suivre mes dons et paiements',
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
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({required IconData icon, required String title, required String subtitle}) {
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
          child: Icon(icon, color: AppColors.textPrimary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: () {},
      ),
    );
  }
}

class _MockDrawer extends StatelessWidget {
  const _MockDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.cardColor),
            child: Text(
              'Menu LeCoinAuto',
              style: TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: AppColors.textPrimary),
            title: const Text('Retour à l\'accueil', style: TextStyle(color: AppColors.textPrimary)),
            onTap: () {
              Navigator.pop(context); // ferme le drawer
              // Dans la vraie app on changerait l'index du MainLayout
            },
          ),
        ],
      ),
    );
  }
}
