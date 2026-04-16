import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/ticket_service.dart';
import '../models/ticket.dart';
import '../widgets/bottom_navigation_service.dart';
import '../widgets/simple_pie_chart.dart';
import 'create_user_screen.dart';
import 'login_screen.dart';
import 'assign_tickets_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

// ÉCRAN TABLEAU DE BORD ADMINISTRATEUR
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  
  // SERVICES ET DONNÉES
  final AuthService _authService = AuthService();
  final TicketService _ticketService = TicketService();
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  int _selectedIndex = 0; // 0: Dashboard, 1: Tickets, 2: Assigner, 3: Utilisateurs
  
  // DONNÉES POUR LA LISTE DES TECHNICIENS
  List<Map<String, dynamic>> _techniciens = [];
  bool _loadingTechniciens = false;
  int _currentPage = 1;
  final int _itemsPerPage = 5;

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

  // CHARGEMENT DES TECHNICIENS
  Future<void> _loadTechniciens() async {
    setState(() => _loadingTechniciens = true);
    try {
      final techniciens = await _ticketService.listerTechniciens(forceRefresh: true);
      setState(() {
        _techniciens = techniciens;
        _currentPage = 1;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _loadingTechniciens = false);
    }
  }

  // SUPPRESSION D'UN TECHNICIEN
  Future<void> _deleteTechnicien(int technicienId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce technicien?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final token = await _authService.getAccessToken();
                final response = await http.delete(
                  Uri.parse('${ApiConfig.baseUrl}/api/users/$technicienId/'),
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                  },
                );
                
                if (mounted) {
                  if (response.statusCode == 204 || response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Technicien supprimé avec succès')),
                    );
                    _loadTechniciens();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: ${response.statusCode}')),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ÉDITION D'UN TECHNICIEN
  Future<void> _editTechnicien(Map<String, dynamic> technicien) async {
    final firstNameCtrl = TextEditingController(text: technicien['first_name'] ?? '');
    final lastNameCtrl = TextEditingController(text: technicien['last_name'] ?? '');
    final emailCtrl = TextEditingController(text: technicien['email'] ?? '');
    final telephoneCtrl = TextEditingController(text: technicien['telephone'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le technicien'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameCtrl,
                decoration: const InputDecoration(labelText: 'Prénom'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lastNameCtrl,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: telephoneCtrl,
                decoration: const InputDecoration(labelText: 'Téléphone'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final token = await _authService.getAccessToken();
                final response = await http.patch(
                  Uri.parse('${ApiConfig.baseUrl}/api/users/${technicien['id']}/'),
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode({
                    'first_name': firstNameCtrl.text,
                    'last_name': lastNameCtrl.text,
                    'email': emailCtrl.text,
                    'telephone': telephoneCtrl.text,
                  }),
                );

                if (mounted) {
                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Technicien modifié avec succès')),
                    );
                    _loadTechniciens();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: ${response.statusCode}')),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
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

    // INTERFACE PRINCIPALE AVEC FOOTER
    return Scaffold(
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
      
      // CORPS PRINCIPAL - SWITCH ENTRE VUES
      body: _buildViewByIndex(_selectedIndex),
      
      // FOOTER DE NAVIGATION
      bottomNavigationBar: BottomNavigationService(
        role: 'ADMIN',
        selectedIndex: _selectedIndex,
        onNavigate: (index) {
          setState(() => _selectedIndex = index);
          // Charger les techniciens si on va à la vue utilisateurs
          if (index == 3 && _techniciens.isEmpty) {
            _loadTechniciens();
          }
        },
      ),
    );
  }

  // CONSTRUCTION DE LA VUE SELON L'INDEX
  Widget _buildViewByIndex(int index) {
    switch (index) {
      case 0:
        // DASHBOARD
        return SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildWelcomeCard(),
                        const SizedBox(height: 24),
                        if (_dashboardData != null) ...[
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth >= 1100;

                              return isWide
                                  ? Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            children: [
                                              _buildSummaryPanel(_dashboardData!),
                                              const SizedBox(height: 16),
                                              _buildActionPanel(),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          flex: 5,
                                          child: _buildMainOverviewPanel(_dashboardData!),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          flex: 2,
                                          child: _buildRightPanel(_dashboardData!),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        _buildSummaryPanel(_dashboardData!),
                                        const SizedBox(height: 16),
                                        _buildMainOverviewPanel(_dashboardData!),
                                        const SizedBox(height: 16),
                                        _buildRightPanel(_dashboardData!),
                                        const SizedBox(height: 16),
                                        _buildActionPanel(),
                                      ],
                                    );
                            },
                          ),
                          const SizedBox(height: 24),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth >= 900) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildBottomLeftPanel(_dashboardData!)),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildBottomRightPanel(_dashboardData!)),
                                  ],
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildBottomLeftPanel(_dashboardData!),
                                  const SizedBox(height: 16),
                                  _buildBottomRightPanel(_dashboardData!),
                                ],
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
              ),
            );
      case 1:
        // TOUS LES TICKETS
        return _buildAllTicketsView();
      case 2:
        // ASSIGNER TICKETS
        return const AssignTicketsScreen();
      case 3:
        // TECHNICIENS
        return _buildTechniciensListView();
      default:
        return const Center(child: Text('Vue non trouvée'));
    }
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

  Widget _buildSummaryPanel(Map<String, dynamic> data) {
    return Column(
      children: [
        _buildStatCard(
          'Total Tickets',
          data['total_tickets'].toString(),
          Icons.receipt_long,
          Colors.indigo,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          'En cours',
          data['tickets_by_status']['EN_COURS'].toString(),
          Icons.work_outline,
          Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          'Résolus',
          data['tickets_by_status']['RESOLU'].toString(),
          Icons.check_circle_outline,
          Colors.green,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          'Clos',
          data['tickets_by_status']['CLOS'].toString(),
          Icons.archive_outlined,
          Colors.grey,
        ),
      ],
    );
  }

  Widget _buildActionPanel() {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildMainOverviewPanel(Map<String, dynamic> data) {
    final statusData = Map<String, int>.from(data['tickets_by_status']);
    final total = statusData.values.fold<int>(0, (sum, value) => sum + value);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Total Tickets vs Statuts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...statusData.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildStatusProgressRow(
                  entry.key,
                  entry.value,
                  total == 0 ? 0 : (entry.value / total),
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryMiniCard(
                    'OUVERT',
                    statusData['OUVERT'].toString(),
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryMiniCard(
                    'CLOS',
                    statusData['CLOS'].toString(),
                    Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightPanel(Map<String, dynamic> data) {
    final users = Map<String, int>.from(data['users_by_role']);
    final totalUsers = data['total_users'] as int;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Utilisateurs du système',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildUserProgressRow('Administrateurs', users['ADMIN'] ?? 0, totalUsers, Colors.red),
                const SizedBox(height: 12),
                _buildUserProgressRow('Techniciens', users['TECHNICIEN'] ?? 0, totalUsers, Colors.blue),
                const SizedBox(height: 12),
                _buildUserProgressRow('Citoyens', users['CITOYEN'] ?? 0, totalUsers, Colors.green),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Utilisateurs totaux',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    totalUsers.toString(),
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomLeftPanel(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SimplePieChart(
          title: 'Répartition des tickets',
          data: [
            PieChartData(label: 'Ouverts', value: data['tickets_by_status']['OUVERT'] ?? 0, color: Colors.orange),
            PieChartData(label: 'En cours', value: data['tickets_by_status']['EN_COURS'] ?? 0, color: Colors.blue),
            PieChartData(label: 'Résolus', value: data['tickets_by_status']['RESOLU'] ?? 0, color: Colors.green),
            PieChartData(label: 'Clos', value: data['tickets_by_status']['CLOS'] ?? 0, color: Colors.grey),
          ],
          size: 200,
        ),
      ],
    );
  }

  Widget _buildBottomRightPanel(Map<String, dynamic> data) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tickets récents',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...((data['recent_tickets'] as List<dynamic>).map((ticket) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      ticket['titre'] ?? 'Sans titre',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ticket['statut'] ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              );
            })).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusProgressRow(String label, int value, double ratio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            Text('${(ratio * 100).round()}%', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: ratio,
          color: label == 'OUVERT'
              ? Colors.orange
              : label == 'EN_COURS'
                  ? Colors.blue
                  : label == 'RESOLU'
                      ? Colors.green
                      : Colors.grey,
          backgroundColor: Colors.grey.withOpacity(0.2),
          minHeight: 8,
        ),
        const SizedBox(height: 8),
        Text('$value tickets', style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildUserProgressRow(String label, int value, int total, Color color) {
    final ratio = total == 0 ? 0.0 : value / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: ratio,
          color: color,
          backgroundColor: Colors.grey.withOpacity(0.2),
          minHeight: 8,
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$value personnes', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text('${(ratio * 100).round()}%', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryMiniCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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

  // VUE TOUS LES TICKETS
  Widget _buildAllTicketsView() {
    final TicketService ticketService = TicketService();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TITRE
            const Text(
              'Tous les Tickets',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // TICKETS RÉCENTS
            FutureBuilder<List<Ticket>>(
              future: ticketService.listerTickets(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erreur: ${snapshot.error}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }

                final tickets = snapshot.data ?? [];

                if (tickets.isEmpty) {
                  return Center(
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
                            'Aucun ticket',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: List.generate(
                    tickets.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildSimpleTicketCard(tickets[index]),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  // CARTE TICKET SIMPLE
  Widget _buildSimpleTicketCard(Ticket ticket) {
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
                    ticket.titre,
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
                    color: _getStatusColor(ticket.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ticket.status,
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
              ticket.description,
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
                    'Type: ${ticket.type}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'Priorité: ${ticket.priorite}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // COULEUR SELON STATUT
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

  // VUE LISTE DES TECHNICIENS AVEC PAGINATION
  Widget _buildTechniciensListView() {
    if (_techniciens.isEmpty && !_loadingTechniciens) {
      return RefreshIndicator(
        onRefresh: _loadTechniciens,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text('Aucun technicien', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadTechniciens,
                  icon: const Icon(Icons.add),
                  label: const Text('Charger les techniciens'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006743),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // PAGINATION
    final totalPages = (_techniciens.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    final paginatedList = _techniciens.sublist(
      startIndex,
      endIndex > _techniciens.length ? _techniciens.length : endIndex,
    );

    return RefreshIndicator(
      onRefresh: _loadTechniciens,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TITRE ET BOUTON
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Techniciens',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateUserScreen()),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006743),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // CHARGEMENT
            if (_loadingTechniciens)
              const Center(child: CircularProgressIndicator())
            else if (paginatedList.isEmpty)
              const Center(child: Text('Aucun technicien à afficher'))
            else
              ...paginatedList.asMap().entries.map((entry) {
                final tech = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // INFO TECHNICIEN
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${tech['first_name']} ${tech['last_name']}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tech['email'] ?? '',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tech['telephone'] ?? 'Pas de téléphone',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // BOUTTONS DE MODIFICATION ET SUPPRESSION
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                    onPressed: () => _editTechnicien(tech),
                                    tooltip: 'Modifier',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                    onPressed: () => _deleteTechnicien(tech['id']),
                                    tooltip: 'Supprimer',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),

            const SizedBox(height: 24),

            // PAGINATION
            if (totalPages > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _currentPage > 1
                        ? () => setState(() => _currentPage--)
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    'Page $_currentPage sur $totalPages',
                    style: const TextStyle(fontSize: 14),
                  ),
                  IconButton(
                    onPressed: _currentPage < totalPages
                        ? () => setState(() => _currentPage++)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}