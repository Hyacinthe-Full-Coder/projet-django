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
  Ticket? _ticket;
  bool _isLoadingAction = false;
  bool _isLoadingInitial = true;
  String? _errorMessage;
  String? _userRole;
  final TextEditingController _commentController = TextEditingController();

  // INITIALISATION
  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadInitialData();
  }

  // CHARGER LE RÔLE DE L'UTILISATEUR
  Future<void> _loadUserRole() async {
    try {
      final profile = await _authService.getUserProfile();
      if (mounted && profile != null) {
        setState(() {
          _userRole = profile['role'];
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  // CHARGER TOUTES LES DONNÉES INITIALES
  Future<void> _loadInitialData() async {
    try {
      setState(() {
        _isLoadingInitial = true;
        _errorMessage = null;
      });

      _ticket = await _ticketService.getTicket(widget.ticketId);
      
      if (mounted) {
        setState(() {
          _isLoadingInitial = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoadingInitial = false;
        });
      }
    }
  }

  // RAFRAÎCHIR LES DONNÉES (SANS RECRÉER LA FUTURE)
  Future<void> _refreshTicket() async {
    try {
      final updatedTicket = await _ticketService.getTicket(widget.ticketId);
      if (mounted) {
        setState(() {
          _ticket = updatedTicket;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du rafraîchissement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ENVOYER UN COMMENTAIRE
  Future<void> _sendComment() async {
    if (_commentController.text.trim().isEmpty || _isLoadingAction) return;
    setState(() => _isLoadingAction = true);
    try {
      await _ticketService.commenter(
        widget.ticketId,
        _commentController.text.trim(),
      );
      _commentController.clear();
      await _refreshTicket();
      
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Commentaire ajouté')));
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

  // CHANGER LE STATUT SANS AFFICHER DE MESSAGE (AUTOMATIQUE)
  Future<void> _changeStatusSilent(String newStatus) async {
    try {
      await _ticketService.changerStatus(widget.ticketId, newStatus);
      await _refreshTicket();
    } catch (e) {
      // Silently fail - pas de notification pour les changements automatiques
    }
  }

  // CHANGER LE STATUT MANUELLEMENT (AVEC MESSAGE)
  Future<void> _changeStatus(String newStatus) async {
    setState(() => _isLoadingAction = true);
    try {
      await _ticketService.changerStatus(widget.ticketId, newStatus);
      await _refreshTicket();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Statut modifié avec succès')),
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

  // COULEUR SELON LE STATUT
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OUVERT':
        return const Color(0xFF006743);
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

  Widget _buildStatusStepper(String status) {
    final isOuvert =
        status == 'OUVERT' ||
        status == 'EN_COURS' ||
        status == 'RESOLU' ||
        status == 'CLOS';
    final isEnCours =
        status == 'EN_COURS' || status == 'RESOLU' || status == 'CLOS';
    final isResolu = status == 'RESOLU' || status == 'CLOS';

    Widget step(String label, IconData icon, bool active) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: active ? const Color(0xFF006743) : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: active ? Colors.white : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: active ? const Color(0xFF006743) : Colors.grey.shade600,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: step('Ouvert', Icons.check_circle, isOuvert)),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 2,
                  color: Colors.grey.shade300,
                  width: double.infinity,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Expanded(child: step('En cours', Icons.autorenew, isEnCours)),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 2,
                  color: Colors.grey.shade300,
                  width: double.infinity,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Expanded(child: step('Résolu', Icons.check, isResolu)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
    if (_isLoadingInitial) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Détails du ticket'),
          backgroundColor: const Color(0xFF006743),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Détails du ticket'),
          backgroundColor: const Color(0xFF006743),
          foregroundColor: Colors.white,
        ),
        body: Center(
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
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadInitialData,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_ticket == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Détails du ticket'),
          backgroundColor: const Color(0xFF006743),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Ticket non trouvé')),
      );
    }

    final ticket = _ticket!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du ticket'),
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTicket,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildStatusStepper(ticket.status),
                    const SizedBox(height: 20),
                    Text(
                      ticket.titre,
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ticket.dateCreation,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              ticket.status,
                            ).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            ticket.status,
                            style: TextStyle(
                              color: _getStatusColor(ticket.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(
                              ticket.priorite,
                            ).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            ticket.priorite,
                            style: TextStyle(
                              color: _getPriorityColor(ticket.priorite),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket.description,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(height: 1.5),
                          ),
                          const SizedBox(height: 18),
                          _buildInfoCard('Type', ticket.type, Icons.category),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            'Auteur',
                            ticket.auteurNom,
                            Icons.person,
                          ),
                          if (ticket.assigneA != null) ...[
                            const SizedBox(height: 12),
                            _buildInfoCard(
                              'Assigné à',
                              ticket.assigneA!,
                              Icons.assignment_ind,
                            ),
                          ],
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            'Date de création',
                            ticket.dateCreation,
                            Icons.calendar_today,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // SECTION GESTION DU STATUT (POUR TECHNICIEN/ADMIN)
                    if (_userRole == 'TECHNICIEN' || _userRole == 'ADMIN') ...[
                      Text(
                        'Gérer le statut du ticket',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // BOUTON RÉSOLU SPÉCIAL (BIEN VISIBLE)
                      if (ticket.status != 'RESOLU' && ticket.status != 'CLOS')
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isLoadingAction ? null : () => _changeStatus('RESOLU'),
                              borderRadius: BorderRadius.circular(18),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isLoadingAction ? Icons.hourglass_top : Icons.check_circle,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _isLoadingAction ? 'Mise à jour...' : 'Marquer comme RÉSOLU',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.grey.shade600,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Ticket déjà résolu',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 24),
                      
                      // GRILLE DE SÉLECTION DES STATUTS
                      Text(
                        'Ou choisir le statut manuellement',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: GridView.count(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildStatusButtonEnhanced('OUVERT', ticket.status),
                            _buildStatusButtonEnhanced('EN_COURS', ticket.status),
                            _buildStatusButtonEnhanced('RESOLU', ticket.status),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    Text(
                      'Commentaires',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (ticket.commentaires.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.grey,
                              size: 24,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Aucun commentaire pour le moment.',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Utilisez le champ ci-dessous pour lancer l\'échange.',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ticket.commentaires.length,
                        itemBuilder: (context, index) {
                          final commentaire = ticket.commentaires[index];
                          final auteur =
                              commentaire['auteur'] as Map<String, dynamic>?;
                          final auteurNom = auteur != null
                              ? '${auteur['first_name']} ${auteur['last_name']}'
                              : 'Inconnu';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      auteurNom,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      commentaire['date'] ?? '',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  commentaire['contenu'] ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Ajouter un commentaire...',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _isLoadingAction ? null : _sendComment,
                    child: Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF006743),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isLoadingAction ? Icons.hourglass_top : Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoadingAction)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.18),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
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

  // BOUTON DE CHANGEMENT DE STATUT (SIMPLE)
  Widget _buildStatusButton(String status, String currentStatus) {
    final isActive = status == currentStatus;
    final isLoading = _isLoadingAction;
    
    return ElevatedButton(
      onPressed: isActive || isLoading ? null : () => _changeStatus(status),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? const Color(0xFF006743) : Colors.grey.shade200,
        foregroundColor: isActive ? Colors.white : Colors.grey.shade700,
        disabledBackgroundColor: Colors.grey.shade200,
        disabledForegroundColor: Colors.grey.shade500,
      ),
      child: Text(status),
    );
  }

  // BOUTON DE CHANGEMENT DE STATUT (AMÉLIORÉ - GRILLE - COMPACT)
  Widget _buildStatusButtonEnhanced(String status, String currentStatus) {
    final isActive = status == currentStatus;
    final isLoading = _isLoadingAction;
    
    // Couleurs selon le statut
    Color getStatusColor(String s) {
      switch (s) {
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

    IconData getStatusIcon(String s) {
      switch (s) {
        case 'OUVERT':
          return Icons.inbox;
        case 'EN_COURS':
          return Icons.work_outline;
        case 'RESOLU':
          return Icons.check_circle_outline;
        case 'CLOS':
          return Icons.archive_outlined;
        default:
          return Icons.help;
      }
    }

    final statusColor = getStatusColor(status);
    final statusIcon = getStatusIcon(status);

    return GestureDetector(
      onTap: isActive || isLoading ? null : () => _changeStatus(status),
      child: Card(
        elevation: isActive ? 3 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isActive ? statusColor : Colors.grey.shade300,
            width: isActive ? 2 : 1,
          ),
        ),
        color: isActive ? statusColor.withOpacity(0.1) : Colors.white,
        child: Container(
          decoration: isActive
              ? BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: statusColor,
                      width: 2,
                    ),
                  ),
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                statusIcon,
                color: isActive ? statusColor : Colors.grey.shade400,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: isActive ? statusColor : Colors.grey.shade700,
                ),
              ),
              if (isActive) ...[
                const SizedBox(height: 2),
                Text(
                  'Actuel',
                  style: TextStyle(
                    fontSize: 8,
                    color: statusColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
