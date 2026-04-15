import 'package:flutter/material.dart';
import '../services/ticket_service.dart';
import '../models/ticket.dart';

// ÉCRAN D'ASSIGNATION DES TICKETS (ADMIN)
class AssignTicketsScreen extends StatefulWidget {
  const AssignTicketsScreen({super.key});

  @override
  State<AssignTicketsScreen> createState() => _AssignTicketsScreenState();
}

class _AssignTicketsScreenState extends State<AssignTicketsScreen> {
  // SERVICES
  final TicketService _ticketService = TicketService();

  // DONNÉES
  List<Ticket> _tickets = [];
  List<Map<String, dynamic>> _techniciens = [];
  bool _isLoading = true;
  String? _selectedFilter = 'non_assignes'; // 'non_assignes' ou 'tous'
  
  // RECHERCHE TECHNICIENS
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // INITIALISATION
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // NETTOYAGE
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // CHARGEMENT DES TICKETS ET TECHNICIENS
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final tickets = await _ticketService.listerTickets();
      final techniciens = await _ticketService.listerTechniciens();

      setState(() {
        _tickets = tickets;
        _techniciens = techniciens;
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

  // FILTRAGE DES TICKETS (NON ASSIGNÉS UNIQUEMENT)
  List<Ticket> get _filteredTickets {
    if (_selectedFilter == 'non_assignes') {
      return _tickets.where((t) => t.assigneA == null).toList();
    }
    return _tickets;
  }

  // FILTRAGE DES TECHNICIENS (PAR RECHERCHE)
  List<Map<String, dynamic>> get _filteredTechniciens {
    if (_searchQuery.isEmpty) {
      return _techniciens;
    }
    final query = _searchQuery.toLowerCase();
    return _techniciens
        .where((tech) =>
            '${tech['first_name']} ${tech['last_name']}'.toLowerCase().contains(query) ||
            (tech['email'] as String).toLowerCase().contains(query))
        .toList();
  }

  // ASSIGNATION D'UN TICKET
  Future<void> _assignTicket(
    Ticket ticket, {
    int? technicienId,
    bool auto = false,
  }) async {
    try {
      await _ticketService.assignerTicket(
        ticket.id,
        technicienId: technicienId,
        auto: auto,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket assigné avec succès')),
        );
        _loadData(); // Recharger les données
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'assignation: ${e.toString()}'),
          ),
        );
      }
    }
  }

  // AFFICHAGE DU DIALOGUE D'ASSIGNATION
  void _showAssignDialog(Ticket ticket) {
    // Réinitialiser la recherche et rafraîchir les techniciens
    _searchController.clear();
    _searchQuery = '';
    _loadTechniciens(forceRefresh: true);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Assigner le ticket #${ticket.id}'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
              minWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // TITRE DU TICKET
                Text('Titre: ${ticket.titre}'),
                const SizedBox(height: 16),
                
                // CHAMP DE RECHERCHE
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un technicien...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'Choisir un technicien:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                
                // LISTE FILTRÉE DES TECHNICIENS
                Expanded(
                  child: _filteredTechniciens.isEmpty
                      ? Center(
                          child: Text(
                            _searchQuery.isEmpty
                                ? 'Aucun technicien disponible'
                                : 'Aucun technicien ne correspond',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredTechniciens.length,
                          itemBuilder: (context, index) {
                            final tech = _filteredTechniciens[index];
                            return ListTile(
                              title: Text(
                                '${tech['first_name']} ${tech['last_name']}',
                              ),
                              subtitle: Text(tech['email']),
                              onTap: () {
                                Navigator.of(context).pop();
                                _assignTicket(
                                  ticket,
                                  technicienId: tech['id'],
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Assignation automatique'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _assignTicket(ticket, auto: true);
              },
              child: const Text('Auto'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
          ],
        ),
      ),
    );
  }

  // CHARGEMENT FORCÉ DES TECHNICIENS
  Future<void> _loadTechniciens({bool forceRefresh = false}) async {
    try {
      final techniciens = await _ticketService.listerTechniciens(
        forceRefresh: forceRefresh,
      );
      if (mounted) {
        setState(() {
          _techniciens = techniciens;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  // CONSTRUCTION DE L'INTERFACE
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BARRE D'APPLICATION
      appBar: AppBar(
        title: const Text('Assigner les Tickets'),
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
      ),

      // CORPS PRINCIPAL
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: Column(
                children: [
                  // SECTION FILTRES
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey.shade100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Filtrer: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            FilterChip(
                              label: const Text('Non assignés'),
                              selected: _selectedFilter == 'non_assignes',
                              onSelected: (selected) {
                                if (selected)
                                  setState(
                                    () => _selectedFilter = 'non_assignes',
                                  );
                              },
                            ),
                            FilterChip(
                              label: const Text('Tous les tickets'),
                              selected: _selectedFilter == 'tous',
                              onSelected: (selected) {
                                if (selected)
                                  setState(() => _selectedFilter = 'tous');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // SECTION LISTE DES TICKETS
                  Expanded(
                    child: _filteredTickets.isEmpty
                        ? Center(
                            child: Text(
                              _selectedFilter == 'non_assignes'
                                  ? 'Aucun ticket non assigné'
                                  : 'Aucun ticket disponible',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredTickets.length,
                            itemBuilder: (context, index) {
                              final ticket = _filteredTickets[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: ListTile(
                                  // TITRE DU TICKET
                                  title: Text(
                                    ticket.titre,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  // INFORMATIONS DÉTAILLÉES
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Type: ${ticket.type} • Priorité: ${ticket.priorite}',
                                      ),
                                      Text('Statut: ${ticket.status}'),
                                      Text('Auteur: ${ticket.auteurNom}'),
                                      if (ticket.assigneA != null)
                                        Text(
                                          'Assigné à: ${ticket.assigneA}',
                                          style: const TextStyle(
                                            color: Colors.green,
                                          ),
                                        ),
                                    ],
                                  ),

                                  // BOUTON D'ASSIGNATION / INDICATEUR
                                  trailing: ticket.assigneA == null
                                      ? ElevatedButton(
                                          onPressed: () =>
                                              _showAssignDialog(ticket),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF006743,
                                            ),
                                          ),
                                          child: const Text('Assigner'),
                                        )
                                      : const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        ),
                                  onTap: () => _showAssignDialog(ticket),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
