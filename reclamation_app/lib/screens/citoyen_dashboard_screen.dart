import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/ticket_service.dart';
import '../widgets/ticket_card.dart';
import '../widgets/bottom_navigation_service.dart';
import 'ticket_detail_screen.dart';
import 'create_ticket_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

// ÉCRAN TABLEAU DE BORD CITOYEN
class CitoyenDashboardScreen extends StatefulWidget {
  const CitoyenDashboardScreen({super.key});

  @override
  State<CitoyenDashboardScreen> createState() => _CitoyenDashboardScreenState();
}

class _CitoyenDashboardScreenState extends State<CitoyenDashboardScreen> {
  // SERVICES ET DONNÉES
  final TicketService _ticketService = TicketService();
  
  late Future<List<Ticket>> _futureTickets;
  String _filterStatus = 'TOUS';
  int _selectedIndex = 0; // 0: Accueil, 1: Mes Tickets, 2: Créer, 3: Notifications
  
  // Statistiques
  Map<String, int> _stats = {
    'total': 0,
    'incidents': 0,
    'reclamations': 0,
    'demandes': 0,
  };

  @override
  void initState() {
    super.initState();
    _charger();
  }

  void _charger({bool forceRefresh = false}) {
    setState(() {
      _futureTickets = _ticketService.listerTickets(
        statut: _filterStatus == 'TOUS' ? null : _filterStatus,
        forceRefresh: forceRefresh,
      );
    });
    _loadStats(forceRefresh: forceRefresh);
  }

  Future<void> _loadStats({bool forceRefresh = false}) async {
    try {
      final tickets = await _ticketService.listerTickets(forceRefresh: forceRefresh);
      setState(() {
        _stats['total'] = tickets.length;
        _stats['incidents'] = tickets.where((t) => t.type == 'INCIDENT').length;
        _stats['reclamations'] =
            tickets.where((t) => t.type == 'RECLAMATION').length;
        _stats['demandes'] = tickets.where((t) => t.type == 'DEMANDE').length;
      });
    } catch (e) {
      // Silently fail
    }
  }



  // CONSTRUCTION DE L'INTERFACE PRINCIPALE
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F2),
      
      // BARRE D'APPLICATION
      appBar: AppBar(
        title: const Text('Accueil'),
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Mon profil',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),

      // CORPS PRINCIPAL (SWITCH ENTRE VUES)
      body: _buildViewByIndex(_selectedIndex),

      // FOOTER DE NAVIGATION
      bottomNavigationBar: BottomNavigationService(
        role: 'CITOYEN',
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
        // ACCUEIL
        return _buildHomeView();
      case 1:
        // MES TICKETS
        return _buildTicketsListView();
      case 2:
        // CRÉER TICKET
        return _buildCreateTicketView();
      case 3:
        // NOTIFICATIONS
        return const NotificationsScreen(role: 'CITOYEN', name: 'Citoyen');
      default:
        return _buildHomeView();
    }
  }

  // VUE ACCUEIL
  Widget _buildHomeView() {
    return RefreshIndicator(
      onRefresh: () async => _charger(forceRefresh: true),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TITRE BIENVENUE
            const Text(
              'Bienvenue',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // STATISTIQUES EN GRILLE
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              children: [
                _buildStatCardCompact(
                  'Total',
                  _stats['total']?.toString() ?? '0',
                  Icons.list_alt,
                  const Color(0xFF006743),
                ),
                _buildStatCardCompact(
                  'Incidents',
                  _stats['incidents']?.toString() ?? '0',
                  Icons.warning_amber_rounded,
                  const Color(0xFFFFA500),
                ),
                _buildStatCardCompact(
                  'Réclamations',
                  _stats['reclamations']?.toString() ?? '0',
                  Icons.receipt_long,
                  const Color(0xFF9C27B0),
                ),
                _buildStatCardCompact(
                  'Demandes',
                  _stats['demandes']?.toString() ?? '0',
                  Icons.help_outline,
                  const Color(0xFF2196F3),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // BOUTON CRÉER UN TICKET
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateTicketScreen()),
                ).then((result) {
                  if (result == true) {
                    _charger(forceRefresh: true);
                    setState(() => _selectedIndex = 1);
                  }
                });
              },
              icon: const Icon(Icons.add_circle),
              label: const Text('Créer un ticket'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006743),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // TICKETS RÉCENTS
            const Text(
              'Mes Tickets Récents',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildRecentTickets(),
          ],
        ),
      ),
    );
  }

  // VUE LISTE DES TICKETS
  Widget _buildTicketsListView() {
    return RefreshIndicator(
      onRefresh: () async => _charger(forceRefresh: true),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TITRE
            const Text(
              'Mes Tickets',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // STATISTIQUES RAPIDES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickStat('Total', _stats['total'] ?? 0),
                _buildQuickStat('Incidents', _stats['incidents'] ?? 0),
                _buildQuickStat('Réclamations', _stats['reclamations'] ?? 0),
                _buildQuickStat('Demandes', _stats['demandes'] ?? 0),
              ],
            ),
            const SizedBox(height: 16),

            // ONGLETS DE FILTRAGE
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTabButton('Tous', _filterStatus == 'TOUS'),
                    const SizedBox(width: 12),
                    _buildTabButton('Ouvert', _filterStatus == 'OUVERT'),
                    const SizedBox(width: 12),
                    _buildTabButton('En cours', _filterStatus == 'EN_COURS'),
                    const SizedBox(width: 12),
                    _buildTabButton('Résolus', _filterStatus == 'RESOLU'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // LISTE DES TICKETS
            FutureBuilder<List<Ticket>>(
              future: _futureTickets,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
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
                            'Aucun ticket trouvé',
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
                      child: TicketCard(
                        ticket: tickets[index],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TicketDetailScreen(ticketId: tickets[index].id),
                          ),
                        ).then((_) => _charger()),
                      ),
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

  // VUE CRÉER TICKET
  Widget _buildCreateTicketView() {
    return RefreshIndicator(
      onRefresh: () async => _charger(forceRefresh: true),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Créer un Ticket',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateTicketScreen()),
                  ).then((result) {
                    if (result == true) {
                      _charger(forceRefresh: true);
                      setState(() => _selectedIndex = 1);
                    }
                  });
                },
                icon: const Icon(Icons.add_circle, size: 32),
                label: const Text(
                  'Nouveau Ticket',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006743),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 30,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Types de tickets disponibles:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTypeInfo('🐛 Incident', 'Problème technique'),
                    const SizedBox(height: 12),
                    _buildTypeInfo(
                        '📝 Réclamation', 'Plainte ou mécontentement'),
                    const SizedBox(height: 12),
                    _buildTypeInfo('❓ Demande', 'Demande de service'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGETS GÉNÉRIQUES

  Widget _buildStatCardCompact(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF006743),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterStatus = label == 'Tous'
              ? 'TOUS'
              : (label == 'Ouvert'
                  ? 'OUVERT'
                  : (label == 'En cours' ? 'EN_COURS' : 'RESOLU'));
        });
        _charger();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF006743) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF90A4AE),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTickets() {
    return FutureBuilder<List<Ticket>>(
      future: _futureTickets,
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

        final tickets = (snapshot.data ?? []).take(3).toList();

        if (tickets.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Aucun ticket pour le moment',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          );
        }

        return Column(
          children: List.generate(
            tickets.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TicketCard(
                ticket: tickets[index],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TicketDetailScreen(ticketId: tickets[index].id),
                  ),
                ).then((_) => _charger()),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeInfo(String type, String description) {
    return Row(
      children: [
        Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            description,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
