import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/ticket_service.dart';
import '../services/auth_service.dart';

// ÉCRAN DÉTAIL D'UN TICKET
class TicketDetailScreen extends StatefulWidget {
  final int ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  
  // SERVICES
  final TicketService _ticketService = TicketService();
  final AuthService _authService = AuthService();
  
  // DONNÉES
  late Future<Ticket> _futureTicket;
  Map<String, dynamic>? _userProfile;
  bool _isLoadingAction = false;
  List<Map<String, dynamic>> _techniciens = [];

  // INITIALISATION
  @override
  void initState() {
    super.initState();
    _futureTicket = _ticketService.getTicket(widget.ticketId);
    _loadUserProfile();
    _loadTechniciens();
  }

  // CHARGEMENT DU PROFIL
  Future<void> _loadUserProfile() async {
    final profile = await _authService.getUserProfile();
    setState(() {
      _userProfile = profile;
    });
  }

  // CHARGEMENT DES TECHNICIENS
  Future<void> _loadTechniciens() async {
    try {
      final techniciens = await _ticketService.listerTechniciens();
      setState(() {
        _techniciens = techniciens;
      });
    } catch (e) {
      print('Erreur chargement techniciens: $e');
    }
  }

  // CHANGER LE STATUT DU TICKET
  Future<void> _changerStatut(String nouveauStatut) async {
    if (_isLoadingAction) return;

    setState(() => _isLoadingAction = true);
    try {
      await _ticketService.changerStatus(widget.ticketId, nouveauStatut);
      setState(() {
        _futureTicket = _ticketService.getTicket(widget.ticketId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Statut changé en $nouveauStatut')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoadingAction = false);
    }
  }

  // ASSIGNER UN TECHNICIEN
  Future<void> _assignerTicket({int? technicienId, bool auto = false}) async {
    if (_isLoadingAction) return;

    setState(() => _isLoadingAction = true);
    try {
      await _ticketService.assignerTicket(widget.ticketId, technicienId: technicienId, auto: auto);
      setState(() {
        _futureTicket = _ticketService.getTicket(widget.ticketId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket assigné avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoadingAction = false);
    }
  }

  // AJOUTER UN COMMENTAIRE
  void _ajouterCommentaire() {
    final controllerCommentaire = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un commentaire'),
        content: TextField(
          controller: controllerCommentaire,
          decoration: const InputDecoration(
            hintText: 'Votre commentaire...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controllerCommentaire.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez écrire un commentaire')),
                );
                return;
              }
              Navigator.pop(context);
              
              setState(() => _isLoadingAction = true);
              try {
                await _ticketService.commenter(widget.ticketId, controllerCommentaire.text);
                setState(() {
                  _futureTicket = _ticketService.getTicket(widget.ticketId);
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Commentaire ajouté')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                  );
                }
              } finally {
                setState(() => _isLoadingAction = false);
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  // DIALOGUE CHANGEMENT DE STATUT
  void _montrerDialogStatut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le statut'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('En cours'),
              onTap: () {
                Navigator.pop(context);
                _changerStatut('EN_COURS');
              },
            ),
            ListTile(
              title: const Text('Résolu'),
              onTap: () {
                Navigator.pop(context);
                _changerStatut('RESOLU');
              },
            ),
            ListTile(
              title: const Text('Clos'),
              onTap: () {
                Navigator.pop(context);
                _changerStatut('CLOS');
              },
            ),
          ],
        ),
      ),
    );
  }

  // DIALOGUE ASSIGNATION
  void _montrerDialogAssignation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assigner un technicien'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _assignerTicket(auto: true);
              },
              icon: const Icon(Icons.shuffle),
              label: const Text('Assignation automatique'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _techniciens.length,
                itemBuilder: (context, index) {
                  final technicien = _techniciens[index];
                  return ListTile(
                    title: Text('${technicien['first_name']} ${technicien['last_name']}'),
                    subtitle: Text(technicien['email']),
                    onTap: () {
                      Navigator.pop(context);
                      _assignerTicket(technicienId: technicien['id']);
                    },
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // COULEUR SELON LE STATUT
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OUVERT':
        return Colors.blue;
      case 'EN_COURS':
        return Colors.orange;
      case 'RESOLU':
        return Colors.green;
      case 'CLOS':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // COULEUR SELON LA PRIORITÉ
  Color _getPriorityColor(String priorite) {
    switch (priorite.toUpperCase()) {
      case 'BASSE':
        return Colors.green;
      case 'NORMALE':
        return Colors.blue;
      case 'HAUTE':
        return Colors.orange;
      case 'CRITIQUE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // CONSTRUCTION DE L'INTERFACE
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BARRE D'APPLICATION
      appBar: AppBar(
        title: const Text('Détails du ticket'),
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
      ),
      
      // CORPS PRINCIPAL
      body: FutureBuilder<Ticket>(
        future: _futureTicket,
        builder: (context, snapshot) {
          // ÉTAT CHARGEMENT
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // ÉTAT ERREUR
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur lors du chargement du ticket',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _futureTicket = _ticketService.getTicket(widget.ticketId);
                      }),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }
          
          final ticket = snapshot.data!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITRE
                Text(
                  ticket.titre,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // STATUT + PRIORITÉ (BADGES)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(ticket.status),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        ticket.status,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(ticket.priorite),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        ticket.priorite,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // INFORMATIONS PRINCIPALES
                _buildInfoCard('Type', ticket.type, Icons.category),
                const SizedBox(height: 12),
                _buildInfoCard('Auteur', ticket.auteurNom, Icons.person),
                const SizedBox(height: 12),
                if (ticket.assigneA != null)
                  _buildInfoCard('Assigné à', ticket.assigneA!, Icons.assignment_ind),
                if (ticket.assigneA != null) const SizedBox(height: 12),
                _buildInfoCard('Date de création', ticket.dateCreation, Icons.calendar_today),
                const SizedBox(height: 20),

                // DESCRIPTION
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ticket.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),

                const SizedBox(height: 24),

                // SECTION ACTIONS
                if (_userProfile != null && (_userProfile!['role'] == 'TECHNICIEN' || _userProfile!['role'] == 'ADMIN')) ...[
                  Row(
                    children: [
                      // BOUTON CHANGER STATUT
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: (_isLoadingAction || (_userProfile!['role'] == 'TECHNICIEN' && ticket.assigneAId == null)) 
                              ? null 
                              : _montrerDialogStatut,
                          icon: _isLoadingAction
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.edit),
                          label: const Text('Changer statut'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006743),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // BOUTON ASSIGNER (ADMIN UNIQUEMENT)
                      if (_userProfile!['role'] == 'ADMIN')
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _techniciens.isEmpty ? null : _montrerDialogAssignation,
                            icon: const Icon(Icons.assignment_ind),
                            label: const Text('Assigner'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                
                // BOUTON COMMENTER
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoadingAction ? null : _ajouterCommentaire,
                        icon: const Icon(Icons.comment),
                        label: const Text('Commenter'),
                      ),
                    ),
                  ],
                ),
                
                // SECTION COMMENTAIRES
                if (ticket.commentaires.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Commentaires',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ticket.commentaires.length,
                    itemBuilder: (context, index) {
                      final commentaire = ticket.commentaires[index];
                      final auteur = commentaire['auteur'] as Map<String, dynamic>?;
                      final auteurNom = auteur != null
                          ? '${auteur['first_name']} ${auteur['last_name']}'
                          : 'Inconnu';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    auteurNom,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    commentaire['date'] ?? '',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                commentaire['contenu'] ?? '',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // CARTE D'INFORMATION GÉNÉRIQUE
  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF006743)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}