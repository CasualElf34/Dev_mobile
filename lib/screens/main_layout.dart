import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'create_annonce_screen.dart';
import 'inbox_screen.dart';
import 'profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text("Boutique (À venir)")), // Placeholder for Boutique
    const InboxScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Pour que le fond violet aille sous la bottom bar si transparente
      body: IndexedStack(
        index: _currentIndex > 1 ? _currentIndex - 1 : _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            currentIndex: _currentIndex,
            onTap: (index) {
              if (index == 2) {
                // Ouvrir la page de création
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateAnnonceScreen()));
              } else {
                setState(() {
                  _currentIndex = index;
                });
              }
            },
            items: [
              const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Recherche'),
              const BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Boutique'),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: AppColors.primary),
                ),
                label: 'Publier',
              ),
              const BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
              const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
            ],
          ),
        ),
      ),
    );
  }
}
