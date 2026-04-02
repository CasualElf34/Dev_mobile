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
    final authService = context.read<AuthService>();
    // Pour le mock, on utilise login
    await authService.login(_emailController.text, _passwordController.text);
    if(mounted) Navigator.pop(context); // Retour ou ignore car main.dart gère le route
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
