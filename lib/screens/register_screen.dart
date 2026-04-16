import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  Future<void> _register() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    // Afficher un loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final authService = context.read<AuthService>();
      await authService.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );
      if(mounted) {
        Navigator.pop(context); // Fermer le loader
        Navigator.pop(context); // Retour à l'écran de connexion ou home
      }
    } catch (e) {
      if(mounted) {
        Navigator.pop(context); // Fermer le loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Nom d\'utilisateur',
                hint: 'Ex: Jean Dupont',
                controller: _nameController,
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Email',
                hint: 'votre@email.com',
                controller: _emailController,
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Mot de passe',
                hint: '••••••••',
                controller: _passwordController,
                prefixIcon: Icons.lock,
                isPassword: true,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'S\'inscrire',
                onPressed: _register,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
