import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../widgets/app_drawer.dart';

// ÉCRAN DES NOTIFICATIONS
class NotificationsScreen extends StatefulWidget {
  final String role;
  final String name;

  const NotificationsScreen({
    super.key,
    required this.role,
    required this.name,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  bool _isMarkingAll = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // CHARGER LES NOTIFICATIONS
  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final notifications = await _notificationService.getNotifications();
      setState(() {
        _notifications = notifications;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // RAFRAÎCHIR LES NOTIFICATIONS
  Future<void> _refreshNotifications() async {
    await _loadNotifications();
  }

  // MARQUER UNE NOTIFICATION COMME LUE
  Future<void> _markAsRead(int notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      await _loadNotifications(); // Recharger pour mettre à jour l'état
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  // MARQUER TOUTES LES NOTIFICATIONS COMME LUES
  Future<void> _markAllAsRead() async {
    setState(() => _isMarkingAll = true);
    try {
      await _notificationService.markAllAsRead();
      await _loadNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Toutes les notifications marquées comme lues')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isMarkingAll = false);
    }
  }

  // SUPPRIMER UNE NOTIFICATION
  Future<void> _deleteNotification(int notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      await _loadNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification supprimée')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  // OBTENIR LA COULEUR SELON LE TYPE DE NOTIFICATION
  Color _getNotificationColor(String type) {
    switch (type) {
      case 'NOUVELLEMENT_ASSIGNE':
        return Colors.blue;
      case 'STATUT_CHANGE':
        return Colors.orange;
      case 'NOUVEAU_COMMENTAIRE':
        return Colors.green;
      case 'TICKET_RESOLU':
        return Colors.teal;
      case 'TICKET_CLOS':
        return Colors.grey;
      case 'SYSTEME':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // OBTENIR L'ICÔNE SELON LE TYPE DE NOTIFICATION
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'NOUVELLEMENT_ASSIGNE':
        return Icons.assignment;
      case 'STATUT_CHANGE':
        return Icons.swap_horiz;
      case 'NOUVEAU_COMMENTAIRE':
        return Icons.comment;
      case 'TICKET_RESOLU':
        return Icons.check_circle;
      case 'TICKET_CLOS':
        return Icons.archive;
      case 'SYSTEME':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // MENU LATÉRAL
      drawer: AppDrawer(
        role: widget.role,
        name: widget.name,
      ),

      // BARRE D'APPLICATION
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
        actions: [
          if (_notifications.any((n) => !(n['est_lue'] ?? false)))
            IconButton(
              icon: _isMarkingAll
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.done_all),
              onPressed: _isMarkingAll ? null : _markAllAsRead,
              tooltip: 'Marquer tout comme lu',
            ),
        ],
      ),

      // CORPS PRINCIPAL
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshNotifications,
              child: _notifications.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Aucune notification',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        final isRead = notification['est_lue'] ?? false;
                        final type = notification['type_notification'] ?? '';
                        final color = _getNotificationColor(type);
                        final icon = _getNotificationIcon(type);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: isRead ? 1 : 3,
                          color: isRead ? Colors.white : color.withOpacity(0.05),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color,
                              child: Icon(
                                icon,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              notification['titre'] ?? '',
                              style: TextStyle(
                                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  notification['message'] ?? '',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(notification['date_creation']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'read':
                                    if (!isRead) {
                                      _markAsRead(notification['id']);
                                    }
                                    break;
                                  case 'delete':
                                    _deleteNotification(notification['id']);
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                if (!isRead)
                                  const PopupMenuItem(
                                    value: 'read',
                                    child: Text('Marquer comme lu'),
                                  ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Supprimer'),
                                ),
                              ],
                            ),
                            onTap: () {
                              if (!isRead) {
                                _markAsRead(notification['id']);
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  // FORMATTER LA DATE
  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Aujourd\'hui ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Hier ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays < 7) {
        return 'Il y a ${difference.inDays} jours';
      } else {
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
}