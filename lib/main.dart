import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/annonce_service.dart';
import 'services/chat_service.dart';
import 'services/location_service.dart';
import 'screens/login_screen.dart';
import 'screens/main_layout.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LeCoinAutoApp());
}

class LeCoinAutoApp extends StatelessWidget {
  const LeCoinAutoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => AnnonceService()),
        ChangeNotifierProvider(create: (_) => ChatService()),
        ChangeNotifierProvider(create: (_) => LocationService()),
      ],
      child: Consumer<AuthService>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'LeCoinAuto',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: auth.isAuthenticated ? const MainLayout() : const LoginScreen(),
          );
        },
      ),
    );
  }
}
