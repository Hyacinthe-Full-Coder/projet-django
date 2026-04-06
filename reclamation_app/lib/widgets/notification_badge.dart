import 'package:flutter/material.dart';
import '../services/ticket_service.dart';

class NotificationBadge extends StatefulWidget {
  final Widget child;
  final TicketService ticketService;

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

  @override
  void initState() {
    super.initState();
    _checkUnreadTickets();
  }

  Future<void> _checkUnreadTickets() async {
    try {
      final tickets = await widget.ticketService.listerTickets(statut: 'OUVERT');
      // Pour cet exemple, on considère tous les tickets ouverts comme non lus
      // Dans un vrai système, il faudrait stocker la date de dernière lecture
      setState(() {
        _unreadCount = tickets.length;
      });
    } catch (e) {
      // Silencieux
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
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