import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'ticket_list_screen.dart';
import 'admin_dashboard_screen.dart';
import 'technicien_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await _authService.getUserProfile();
    setState(() {
      _userProfile = profile;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Rediriger selon le rôle
    if (_userProfile != null) {
      final role = _userProfile!['role'];
      if (role == 'ADMIN') {
        return const AdminDashboardScreen();
      } else if (role == 'TECHNICIEN') {
        return const TechnicienDashboardScreen();
      }
    }

    // Par défaut, écran des tickets pour citoyens
    return TicketListScreen(
      role: 'CITOYEN',
      name: '${_userProfile?['first_name'] ?? 'Utilisateur'} ${_userProfile?['last_name'] ?? ''}',
    );
  }
}
