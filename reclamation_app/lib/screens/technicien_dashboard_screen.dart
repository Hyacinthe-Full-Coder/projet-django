import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/app_drawer.dart';
import 'ticket_list_screen.dart';
import 'login_screen.dart';

// ÉCRAN TABLEAU DE BORD TECHNICIEN
class TechnicienDashboardScreen extends StatefulWidget {
  const TechnicienDashboardScreen({super.key});

  @override
  State<TechnicienDashboardScreen> createState() => _TechnicienDashboardScreenState();
}

class _TechnicienDashboardScreenState extends State<TechnicienDashboardScreen> {
  
  // SERVICES ET DONNÉES
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  int _selectedIndex = 0;  // 0: Dashboard, 1: Liste des tickets

  // INITIALISATION
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // CHARGEMENT DES DONNÉES
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      // MENU LATÉRAL
      drawer: AppDrawer(
        role: 'TECHNICIEN',
        name: '${_userProfile?['first_name']} ${_userProfile?['last_name']}',
        onLogout: _logout,
      ),
      
      // BARRE D'APPLICATION
      appBar: AppBar(
        title: const Text('Dashboard Technicien'),
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      
      // CORPS PRINCIPAL (SWITCH ENTRE VUES)
      body: _selectedIndex == 0
          ? _buildDashboardView()
          : TicketListScreen(
              role: 'TECHNICIEN',
              name: '${_userProfile?['first_name'] ?? 'Technicien'} ${_userProfile?['last_name'] ?? ''}',
            ),
      
      // BARRE DE NAVIGATION INFÉRIEURE
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: const Color(0xFF006743),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Mes Tickets',
          ),
        ],
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  // VUE TABLEAU DE BORD
  Widget _buildDashboardView() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // SECTION BIENVENUE
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF006743),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.support_agent,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bienvenue Technicien',
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
            ),
            const SizedBox(height: 24),

            // SECTION STATISTIQUES
            if (_dashboardData != null) ...[
              // TOTAL TICKETS ASSIGNÉS
              _buildStatCard(
                'Tickets Assignés',
                (_dashboardData!['total_tickets_assignes'] ?? 0).toString(),
                Icons.assignment,
                Colors.blue,
              ),
              const SizedBox(height: 16),

              // TICKETS PAR STATUT
              const Text(
                'Mes Tickets par Statut',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildTicketStatsGrid(
                (_dashboardData!['my_tickets'] as Map<String, dynamic>?) ?? {},
              ),
              const SizedBox(height: 24),

              // TICKETS RÉCENTS
              const Text(
                'Tickets Récents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (_dashboardData!['recent_tickets'] != null &&
                  (_dashboardData!['recent_tickets'] as List).isNotEmpty)
                _buildRecentTickets(_dashboardData!['recent_tickets'])
              else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Aucun ticket récent'),
                  ),
                ),
            ] else
              const Center(
                child: Text('Erreur lors du chargement des données'),
              ),
          ],
        ),
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
    return SizedBox(
      height: 80,
      child: Container(
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
      ),
    );
  }

  // GRILLE DES STATISTIQUES PAR STATUT
  Widget _buildTicketStatsGrid(Map<String, dynamic> stats) {
    final colors = {
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

  // LISTE DES TICKETS RÉCENTS
  Widget _buildRecentTickets(List<dynamic> tickets) {
    return Column(
      children: tickets.map((ticket) {
        final statusColor = _getStatusColor(ticket['statut']);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LIGNE TITRE + STATUT
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ticket['titre'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ticket['statut'] ?? '',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // LIGNE TYPE + PRIORITÉ
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Type: ${ticket['type_ticket'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'Priorité: ${ticket['priorite'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // COULEUR SELON LE STATUT
  Color _getStatusColor(String status) {
    switch (status) {
      case 'OUVERT':
        return Colors.orange;
      case 'EN_COURS':
        return Colors.blue;
      case 'RESOLU':
        return Colors.green;
      case 'CLOS':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}