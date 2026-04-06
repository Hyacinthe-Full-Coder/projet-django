import 'package:flutter/material.dart';
import '../services/ticket_service.dart';

// BADGE DE NOTIFICATION POUR TICKETS OUVERTS
// Affiche un indicateur rouge avec le nombre de tickets ouverts non lus
class NotificationBadge extends StatefulWidget {
  final Widget child;           // Widget enfant (bouton filtre)
  final TicketService ticketService;  // Service pour récupérer les tickets

  const NotificationBadge({
    super.key,
    required this.child,
    required this.ticketService,
  });

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  int _unreadCount = 0;

  // INITIALISATION
  @override
  void initState() {
    super.initState();
    _checkUnreadTickets();
  }

  // VÉRIFICATION DES TICKETS OUVERTS
  Future<void> _checkUnreadTickets() async {
    try {
      final tickets = await widget.ticketService.listerTickets(statut: 'OUVERT');
      // Note : les tickets ouverts sont considérés comme non lus
      // Dans une version réelle, il faudrait comparer avec la date de dernière lecture
      setState(() {
        _unreadCount = tickets.length;
      });
    } catch (e) {
      // Erreur silencieuse pour ne pas casser l'interface
    }
  }

  // CONSTRUCTION DE L'INTERFACE
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // WIDGET ENFANT (icône filtre)
        widget.child,
        
        // BADGE DE NOTIFICATION (si > 0)
        if (_unreadCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                _unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}