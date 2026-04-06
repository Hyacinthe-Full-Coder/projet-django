import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

// POINT D'ENTRÉE DE L'APPLICATION FLUTTER
void main() {
  runApp(const MyApp());
}

// APPLICATION PRINCIPALE
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // TITRE DE L'APPLICATION
      title: 'Gestion des réclamations',
      
      // MASQUER LE BANNIÈRE DE DEBUG
      debugShowCheckedModeBanner: false,
      
      // THÈME DE L'APPLICATION
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      
      // ÉCRAN D'ACCUEIL (PAGE DE CONNEXION)
      home: const LoginScreen(),
    );
  }
}