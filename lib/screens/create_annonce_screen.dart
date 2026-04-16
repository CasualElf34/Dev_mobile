import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/photo_picker.dart';
import '../models/annonce_model.dart';
import '../services/annonce_service.dart';
import '../services/location_service.dart';
import 'package:provider/provider.dart';

class CreateAnnonceScreen extends StatefulWidget {
  const CreateAnnonceScreen({super.key});

  @override
  State<CreateAnnonceScreen> createState() => _CreateAnnonceScreenState();
}

class _CreateAnnonceScreenState extends State<CreateAnnonceScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  
  AnnonceCategory _selectedCategory = AnnonceCategory.panne;
  List<File> _selectedPhotos = [];

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _submit();
    }
  }

  void _submit() async {
    final service = context.read<AnnonceService>();
    final locationService = context.read<LocationService>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await locationService.getCurrentPosition();
      double lat = locationService.currentPosition?.latitude ?? 48.8566;
      double lng = locationService.currentPosition?.longitude ?? 2.3522;

      final tempAnnonce = AnnonceModel(
        id: '',
        authorId: '',
        title: _titleController.text.isNotEmpty ? _titleController.text : 'Nouvelle annonce',
        description: _descController.text,
        category: _selectedCategory,
        photosUrl: [],
        latitude: lat,
        longitude: lng,
        createdAt: DateTime.now(),
        suggestedPrice: double.tryParse(_priceController.text),
      );

      await service.createAnnonce(tempAnnonce, _selectedPhotos);
      
      if(mounted) {
        Navigator.pop(context); // fermer loader
        Navigator.pop(context); // retour
      }
    } catch (e) {
      if(mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PUBLIER', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Indicateur d'étape (simple padding / text)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 30,
                height: 4,
                decoration: BoxDecoration(
                  color: _currentPage >= index ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              )),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Empêche le drag manuel
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: [
                _buildStepType(),
                _buildStepPhotos(),
                _buildStepLocalization(),
                _buildStepDetails(),
                _buildStepPrice(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: Text(
                  _currentPage == 4 ? 'TERMINER' : 'SUIVANT',
                  style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({required String title, required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: child,
          )
        ],
      ),
    );
  }

  Widget _buildStepType() {
    return _buildStepCard(
      title: 'TYPE DE PANNE/ANNONCE',
      child: Column(
        children: [
          _buildCategoryOption(AnnonceCategory.panne, 'Panne mécanique'),
          const SizedBox(height: 16),
          _buildCategoryOption(AnnonceCategory.piece, 'Recherche de pièce'),
          const SizedBox(height: 16),
          _buildCategoryOption(AnnonceCategory.conseil, 'Besoin de conseil'),
        ],
      ),
    );
  }

  Widget _buildCategoryOption(AnnonceCategory category, String label) {
    bool isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepPhotos() {
    return _buildStepCard(
      title: 'IMAGES / PHOTOS',
      child: PhotoPicker(
        onPhotosSelected: (files) {
          setState(() => _selectedPhotos = files);
        },
      ),
    );
  }

  Widget _buildStepLocalization() {
    return _buildStepCard(
      title: 'LOCALISATION',
      child: Consumer<LocationService>(
        builder: (context, loc, _) {
          return Column(
            children: [
              const Icon(Icons.map, size: 60, color: AppColors.background),
              const SizedBox(height: 16),
              Text(
                loc.currentAddress ?? 'Veuillez autoriser la localisation',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => loc.getCurrentPosition(),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Actualiser ma position'),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepDetails() {
    return _buildStepCard(
      title: 'DÉTAILS',
      child: Column(
        children: [
          CustomTextField(
            label: 'Titre de l\'annonce',
            hint: 'Ex: Panne de batterie Clio 4',
            controller: _titleController,
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'Description détaillée',
            hint: 'Donnez un maximum d\'informations...',
            controller: _descController,
          ),
        ],
      ),
    );
  }

  Widget _buildStepPrice() {
    return _buildStepCard(
      title: 'PRIX',
      child: Column(
        children: [
          const Text(
            'Combien êtes-vous prêt à offrir en remerciement ?',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'Don suggéré (€)',
            hint: 'Ex: 15',
            controller: _priceController,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}
