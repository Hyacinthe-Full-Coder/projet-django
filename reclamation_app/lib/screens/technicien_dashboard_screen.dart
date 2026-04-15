import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/bottom_navigation_service.dart';
import 'login_screen.dart';
import 'statistics_screen.dart';
import 'notifications_screen.dart';

// ÉCRAN TABLEAU DE BORD TECHNICIEN
class TechnicienDashboardScreen extends StatefulWidget {
  const TechnicienDashboardScreen({super.key});

  @override
  State<TechnicienDashboardScreen> createState() =>
      _TechnicienDashboardScreenState();
}

class _TechnicienDashboardScreenState extends State<TechnicienDashboardScreen> {
  // SERVICES ET DONNÉES
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  int _selectedIndex = 0; // 0: Dashboard, 1: Liste des tickets

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      // BARRE D'APPLICATION
      appBar: AppBar(
        title: const Text('Dashboard Technicien'),
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),

      // CORPS PRINCIPAL (SWITCH ENTRE VUES)
      body: _buildViewByIndex(_selectedIndex),

      // FOOTER DE NAVIGATION
      bottomNavigationBar: BottomNavigationService(
        role: 'TECHNICIEN',
        selectedIndex: _selectedIndex,
        onNavigate: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }

  // CONSTRUCTION DE LA VUE SELON L'INDEX
  Widget _buildViewByIndex(int index) {
    switch (index) {
      case 0:
        // DASHBOARD
        return _buildDashboardView();
      case 1:
        // MES TICKETS
        return _buildMyTicketsView();
      case 2:
        // STATISTIQUES
        return const StatisticsScreen();
      case 3:
        // NOTIFICATIONS
        return NotificationsScreen(
          role: 'TECHNICIEN',
          name: '${_userProfile?['first_name']} ${_userProfile?['last_name']}',
        );
      default:
        return const Center(child: Text('Vue non trouvée'));
    }
  }

  // VUE TABLEAU DE BORD
  Widget _buildDashboardView() {
    final myTickets =
        (_dashboardData!['my_tickets'] as Map<String, dynamic>?) ?? {};

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // SECTION BIENVENUE
                Container(
                  width: double.infinity,
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
                  Center(
                    child: _buildStatCard(
                      'Total Tickets',
                      (_dashboardData!['total_tickets_assignes'] ?? 0)
                          .toString(),
                      Icons.event_note,
                      Colors.indigo,
                      width: 140,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // TICKETS PAR STATUT
                  const Text(
                    'Mes Tickets par Statut',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Column(
                      children: [
                        _buildStatCard(
                          'En cours',
                          (myTickets['EN_COURS'] ?? 0).toString(),
                          Icons.work_outline,
                          Colors.blue,
                          width: 140,
                        ),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          'Résolus',
                          (myTickets['RESOLU'] ?? 0).toString(),
                          Icons.check_circle,
                          Colors.green,
                          width: 140,
                        ),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          'Clos',
                          (myTickets['CLOS'] ?? 0).toString(),
                          Icons.archive,
                          Colors.grey,
                          width: 140,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // TICKETS RÉCENTS
                  const Text(
                    'Tickets Récents',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
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
        ),
      ),
    );
  }

  // CARTE STATISTIQUE GÉNÉRIQUE
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    double width = double.infinity,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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

  // VUE MES TICKETS
  Widget _buildMyTicketsView() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TITRE
            const Text(
              'Mes Tickets Assignés',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // FICHES STATISTIQUES
            if (_dashboardData != null) ...[
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.2,
                children: [
                  _buildStatCardCompact(
                    'En cours',
                    (_dashboardData?['my_tickets']['EN_COURS'] ?? 0)
                        .toString(),
                    Icons.work,
                    Colors.blue,
                  ),
                  _buildStatCardCompact(
                    'Résolus',
                    (_dashboardData?['my_tickets']['RESOLU'] ?? 0)
                        .toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                  _buildStatCardCompact(
                    'Clos',
                    (_dashboardData?['my_tickets']['CLOS'] ?? 0)
                        .toString(),
                    Icons.archive,
                    Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // MESSAGE
            const Text(
              'Tickets à Traiter',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // AFFICHAGE DES TICKETS RÉCENTS
            if (_dashboardData?['recent_tickets'] != null &&
                (_dashboardData!['recent_tickets'] as List).isNotEmpty)
              Column(
                children: List.generate(
                  (_dashboardData!['recent_tickets'] as List).length,
                  (index) {
                    final ticket = (_dashboardData!['recent_tickets'] as List)[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildSimpleTicketCard(ticket),
                    );
                  },
                ),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun ticket pour le moment',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // CARTE STATISTIQUE COMPACTE
  Widget _buildStatCardCompact(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // CARTE TICKET SIMPLE (SANS TICKET CARD)
  Widget _buildSimpleTicketCard(Map<String, dynamic> ticket) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITRE + STATUT
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    ticket['titre'] ?? 'Sans titre',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(ticket['statut'] ?? ''),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ticket['statut'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // DESCRIPTION
            Text(
              ticket['description'] ?? '',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // TYPE + PRIORITÉ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Type: ${ticket['type_ticket'] ?? ''}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'Priorité: ${ticket['priorite'] ?? ''}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
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
