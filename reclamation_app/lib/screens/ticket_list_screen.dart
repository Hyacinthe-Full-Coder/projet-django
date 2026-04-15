import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/ticket_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/ticket_card.dart';
import 'ticket_detail_screen.dart';
import 'create_ticket_screen.dart';
import 'profile_screen.dart';

class TicketListScreen extends StatefulWidget {
  final String role;
  final String name;

  const TicketListScreen({super.key, required this.role, required this.name});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  final _service = TicketService();
  late Future<List<Ticket>> _futureTickets;
  String _filterStatus = 'TOUS';
  
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

  void _charger() {
    setState(() {
      _futureTickets = _service.listerTickets(
        statut: _filterStatus == 'TOUS' ? null : _filterStatus,
      );
    });
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final tickets = await _service.listerTickets();
      setState(() {
        _stats['total'] = tickets.length;
        _stats['incidents'] = tickets.where((t) => t.type == 'INCIDENT').length;
        _stats['reclamations'] = tickets.where((t) => t.type == 'RECLAMATION').length;
        _stats['demandes'] = tickets.where((t) => t.type == 'DEMANDE').length;
      });
    } catch (e) {
      // Silently fail
    }
  }

  Widget _buildStatCard(String label, int value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263238),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF90A4AE),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterStatus = label == 'Tous' ? 'TOUS' : 
                          (label == 'Ouvert' ? 'OUVERT' : 
                          (label == 'En cours' ? 'EN_COURS' : 'RESOLU'));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F2),
      drawer: AppDrawer(
        role: widget.role,
        name: widget.name,
        onLogout: null,
      ),
      appBar: AppBar(
        title: const Text('Mes Tickets'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // STATISTIQUES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(
                  'Tous',
                  _stats['total'] ?? 0,
                  Icons.list_alt,
                  const Color(0xFF006743),
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  'Incidents',
                  _stats['incidents'] ?? 0,
                  Icons.warning_amber_rounded,
                  const Color(0xFFFFA500),
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  'Réclamations',
                  _stats['reclamations'] ?? 0,
                  Icons.receipt_long,
                  const Color(0xFF9C27B0),
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  'Demandes',
                  _stats['demandes'] ?? 0,
                  Icons.help_outline,
                  const Color(0xFF2196F3),
                ),
              ],
            ),
            const SizedBox(height: 20),

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

            // TITRE SECTION
            const Text(
              'INCIDENTS RÉCENTS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF90A4AE),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

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
                      child: Text(
                        'Aucun ticket trouvé',
                        style: TextStyle(
                          color: Color(0xFF90A4AE),
                          fontSize: 15,
                        ),
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
                            builder: (_) => TicketDetailScreen(ticketId: tickets[index].id),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateTicketScreen()),
        ).then((_) => _charger()),
        backgroundColor: const Color(0xFF006743),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
