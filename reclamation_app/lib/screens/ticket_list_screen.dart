import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/ticket_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/ticket_card.dart';
import '../widgets/notification_badge.dart';
import 'ticket_detail_screen.dart';
import 'create_ticket_screen.dart';

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
  }

  Color _couleurStatus(String status) {
    switch (status) {
      case 'OUVERT':
        return Colors.blue;
      case 'EN_COURS':
        return Colors.orange;
      case 'RESOLU':
        return Colors.green;
      case 'CLOS':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
        role: widget.role,
        name: widget.name,
        onLogout: null,
      ),
      appBar: AppBar(
        title: const Text('Mes Tickets'),
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
        actions: [
          NotificationBadge(
            ticketService: _service,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              onSelected: (val) {
                setState(() {
                  _filterStatus = val ?? 'TOUS';
                });
                _charger();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'TOUS', child: Text('Tous')),
                const PopupMenuItem(value: 'OUVERT', child: Text('Ouvert')),
                const PopupMenuItem(value: 'EN_COURS', child: Text('En Cours')),
                const PopupMenuItem(value: 'RESOLU', child: Text('Résolu')),
                const PopupMenuItem(value: 'CLOS', child: Text('Clos')),
              ],
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Ticket>>(
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
            return const Center(child: Text('Aucun ticket trouvé'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              _charger();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: tickets.length,
              itemBuilder: (_, i) => TicketCard(
                ticket: tickets[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TicketDetailScreen(ticketId: tickets[i].id),
                  ),
                ).then((_) => _charger()),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CreateTicketScreen()),
        ).then((_) => _charger()),
        label: const Text('Nouveau Ticket'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF006743),
      ),
    );
  }
}
