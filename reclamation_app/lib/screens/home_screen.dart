import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'citoyen_dashboard_screen.dart';
import 'admin_dashboard_screen.dart';
import 'technicien_dashboard_screen.dart';

// ÉCRAN D'ACCUEIL AVEC REDIRECTION SELON LE RÔLE
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  // SERVICES ET DONNÉES
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  // CHARGEMENT DU PROFIL À L'INITIALISATION
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // RÉCUPÉRATION DU PROFIL UTILISATEUR
  Future<void> _loadUserProfile() async {
    final profile = await _authService.getUserProfile();
    setState(() {
      _userProfile = profile;
      _isLoading = false;
    });
  }

  // CONSTRUCTION DE L'INTERFACE
  @override
  Widget build(BuildContext context) {
    
    // AFFICHAGE CHARGEMENT
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // REDIRECTION SELON LE RÔLE
    if (_userProfile != null) {
      final role = _userProfile!['role'];
      
      // ADMIN → DASHBOARD ADMIN
      if (role == 'ADMIN') {
        return const AdminDashboardScreen();
      } 
      // TECHNICIEN → DASHBOARD TECHNICIEN
      else if (role == 'TECHNICIEN') {
        return const TechnicienDashboardScreen();
      }
    }

    // PAR DÉFAUT : DASHBOARD CITOYEN
    return const CitoyenDashboardScreen();
  }
}