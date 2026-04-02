import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
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
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  
  AnnonceCategory _selectedCategory = AnnonceCategory.panne;

  void _submit() async {
    final service = context.read<AnnonceService>();
    final locationService = context.read<LocationService>();

    // Demande et récupération de la position de l'utilisateur
    await locationService.getCurrentPosition();
    double lat = locationService.currentPosition?.latitude ?? 48.8566;
    double lng = locationService.currentPosition?.longitude ?? 2.3522;

    final newAnnonce = AnnonceModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorId: 'mock_user_123',
      title: _titleController.text.isNotEmpty ? _titleController.text : 'Nouvelle annonce',
      description: _descController.text,
      category: _selectedCategory,
      photosUrl: [],
      latitude: lat,
      longitude: lng,
      createdAt: DateTime.now(),
      suggestedPrice: double.tryParse(_priceController.text),
    );

    await service.createAnnonce(newAnnonce);
    if(mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publier une annonce'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Catégorie", style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            SegmentedButton<AnnonceCategory>(
              segments: const [
                ButtonSegment(value: AnnonceCategory.panne, label: Text('Panne')),
                ButtonSegment(value: AnnonceCategory.piece, label: Text('Pièce')),
                ButtonSegment(value: AnnonceCategory.conseil, label: Text('Conseil')),
              ],
              selected: {_selectedCategory},
              onSelectionChanged: (Set<AnnonceCategory> newSelection) {
                setState(() {
                  _selectedCategory = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 24),
            CustomTextField(
              label: 'Titre de l\'annonce',
              hint: 'Ex: Panne de batterie Clio 4',
              controller: _titleController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Description',
              hint: 'Détaillez votre besoin ou la pièce voulue...',
              controller: _descController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Don suggéré / Prix (€)',
              hint: 'Ex: 15',
              controller: _priceController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            PhotoPicker(
              onPhotosSelected: (files) {
                // gérer l'ajout de photos
              },
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: 'Publier',
              onPressed: _submit,
            )
          ],
        ),
      ),
    );
  }
}
