import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/app_drawer.dart';
import 'statistics_screen.dart';
import 'create_user_screen.dart';
import 'login_screen.dart';
import 'assign_tickets_screen.dart';

// ÉCRAN TABLEAU DE BORD ADMINISTRATEUR
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  
  // SERVICES ET DONNÉES
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  // INITIALISATION
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // CHARGEMENT DES DONNÉES (PROFIL + DASHBOARD)
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _authService.getUserProfile();
      final dashboard = await _authService.getDashboard();
      setState(() {
        _userProfile = profile;
        _dashboardData = dashboard;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // DÉCONNEXION
  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  // CONSTRUCTION DE L'INTERFACE
  @override
  Widget build(BuildContext context) {
    
    // VÉRIFICATION DES DROITS ADMIN
    if (_userProfile == null || _userProfile!['role'] != 'ADMIN') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Administration'),
          backgroundColor: const Color(0xFF006743),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'Accès refusé. Réservé aux administrateurs.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // INTERFACE PRINCIPALE
    return Scaffold(
      // MENU LATÉRAL
      drawer: AppDrawer(
        role: 'ADMIN',
        name: '${_userProfile?['first_name']} ${_userProfile?['last_name']}',
        onLogout: _logout,
      ),
      
      // BARRE D'APPLICATION
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      
      // CORPS PRINCIPAL
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // SECTION BIENVENUE
                      _buildWelcomeCard(),
                      const SizedBox(height: 24),

                      // SECTION STATISTIQUES PRINCIPALES
                        if (_dashboardData != null) ...[
                          _buildStatCard(
                            'Total Tickets',
                            _dashboardData!['total_tickets'].toString(),
                            Icons.receipt_outlined,
                            Colors.blue,
                          ),
                          const SizedBox(height: 16),

                          // SECTION STATISTIQUES PAR STATUT
                          const Text(
                            'Tickets par Statut',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildTicketStatsGrid(
                              _dashboardData!['tickets_by_status']),
                          const SizedBox(height: 24),

                          // SECTION UTILISATEURS
                          const Text(
                            'Utilisateurs du Système',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildUserStatsGrid(_dashboardData!['users_by_role']),
                          const SizedBox(height: 24),
                        ],

                      // SECTION ACTIONS ADMIN
                      const Text(
                        'Actions Administrateur',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildAdminCard(
                        'Assigner Tickets',
                        'Gérer l\'assignation des tickets aux techniciens',
                        Icons.assignment,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AssignTicketsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildAdminCard(
                        'Créer Utilisateur',
                        'Ajouter un admin ou technicien',
                        Icons.person_add,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateUserScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('test'),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
        );
  }

  // CARTE DE BIENVENUE
  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF006743),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.admin_panel_settings,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bienvenue Administrateur',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_userProfile?['first_name']} ${_userProfile?['last_name']}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CARTE STATISTIQUE GÉNÉRIQUE
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withAlpha(180), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // GRILLE DES STATISTIQUES DES TICKETS
  Widget _buildTicketStatsGrid(Map<String, dynamic> stats) {
    final colors = {
      'OUVERT': Colors.orange,
      'EN_COURS': Colors.blue,
      'RESOLU': Colors.green,
      'CLOS': Colors.grey,
    };

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
      childAspectRatio: 2.5,
      children: stats.entries.map((e) {
        return _buildStatCard(
          e.key,
          e.value.toString(),
          Icons.circle,
          colors[e.key] ?? Colors.grey,
        );
      }).toList(),
    );
  }

  // GRILLE DES STATISTIQUES DES UTILISATEURS
  Widget _buildUserStatsGrid(Map<String, dynamic> stats) {
    final colors = {
      'ADMIN': Colors.red,
      'TECHNICIEN': Colors.blue,
      'CITOYEN': Colors.green,
    };

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
      childAspectRatio: 2.5,
      children: stats.entries.map((e) {
        return _buildStatCard(
          e.key,
          e.value.toString(),
          Icons.group,
          colors[e.key] ?? Colors.grey,
        );
      }).toList(),
    );
  }

  // CARTE D'ACTION ADMIN
  Widget _buildAdminCard(
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF006743).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF006743),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}