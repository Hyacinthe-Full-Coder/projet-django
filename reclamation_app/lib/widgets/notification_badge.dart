import 'package:flutter/material.dart';
import '../services/notification_service.dart';

// BADGE DE NOTIFICATION POUR NOTIFICATIONS NON LUES
// Affiche un indicateur rouge avec le nombre de notifications non lues
class NotificationBadge extends StatefulWidget {
  final Widget child;           // Widget enfant (icône)
  final NotificationService? service;  // Service pour récupérer les notifications (optionnel)

  const NotificationBadge({
    super.key,
    required this.child,
    this.service,
  });

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  int _unreadCount = 0;
  NotificationService? _service;

  // INITIALISATION
  @override
  void initState() {
    super.initState();
    _service = widget.service ?? NotificationService();
    _checkUnreadNotifications();
  }

  // VÉRIFICATION DES NOTIFICATIONS NON LUES
  Future<void> _checkUnreadNotifications() async {
    if (_service == null) return;

    try {
      final count = await _service!.getUnreadCount();
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (e) {
      // Erreur silencieuse pour ne pas casser l'interface
      if (mounted) {
        setState(() {
          _unreadCount = 0;
        });
      }
    }
  }

  // MISE À JOUR PÉRIODIQUE
  @override
  void didUpdateWidget(NotificationBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.service != oldWidget.service) {
      _service = widget.service ?? NotificationService();
      _checkUnreadNotifications();
    }
  }

  // CONSTRUCTION DE L'INTERFACE
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // WIDGET ENFANT (icône)
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
                _unreadCount > 99 ? '99+' : _unreadCount.toString(),
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

  @override
  void dispose() {
    _service?.dispose();
    super.dispose();
  }
}