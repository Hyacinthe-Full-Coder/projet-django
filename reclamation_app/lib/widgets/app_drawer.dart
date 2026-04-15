import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/technicien_dashboard_screen.dart';
import '../screens/ticket_list_screen.dart';
import '../screens/create_ticket_screen.dart';
import '../screens/assign_tickets_screen.dart';
import '../screens/create_user_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/login_screen.dart';
import 'notification_badge.dart';

// MENU LATÉRAL DE NAVIGATION
// Affiche différentes options selon le rôle de l'utilisateur (ADMIN, TECHNICIEN, CITOYEN)
class AppDrawer extends StatelessWidget {
  final String role;
  final String name;
  final VoidCallback? onLogout;

  const AppDrawer({
    super.key,
    required this.role,
    required this.name,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // EN-TÊTE DU MENU (PROFIL UTILISATEUR)
            UserAccountsDrawerHeader(
              accountName: Text(name),
              accountEmail: Text(role),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF006743)),
              ),
              decoration: const BoxDecoration(color: Color(0xFF006743)),
            ),
            
            // SECTION ADMIN
            if (role == 'ADMIN') ...[
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Dashboard'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                  );
                },
              ),
              _buildNotificationsTile(context),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Mes Tickets'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TicketListScreen(
                        role: role,
                        name: name,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.assignment),
                title: const Text('Assigner Tickets'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AssignTicketsScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('Créer un utilisateur'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CreateUserScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Statistiques'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                  );
                },
              ),
            ] 
            
            // SECTION TECHNICIEN
            else if (role == 'TECHNICIEN') ...[
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Dashboard'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const TechnicienDashboardScreen()),
                  );
                },
              ),
              _buildNotificationsTile(context),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Mes Tickets'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TicketListScreen(
                        role: role,
                        name: name,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Statistiques'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                  );
                },
              ),
            ] 
            
            // SECTION CITOYEN
            else ...[
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Créer un ticket'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateTicketScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Voir mes tickets'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TicketListScreen(
                        role: role,
                        name: name,
                      ),
                    ),
                  );
                },
              ),
              _buildNotificationsTile(context),
            ],
            
            const Spacer(),
            const Divider(),
            
            // BOUTON DÉCONNEXION
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () async {
                await AuthService().logout();
                if (onLogout != null) {
                  onLogout!();
                }
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // MÉTHODE POUR CONSTRUIRE LE TILE DES NOTIFICATIONS AVEC BADGE
  Widget _buildNotificationsTile(BuildContext context) {
    return ListTile(
      leading: NotificationBadge(
        child: const Icon(Icons.notifications),
        service: NotificationService(),
      ),
      title: const Text('Notifications'),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotificationsScreen(
              role: role,
              name: name,
            ),
          ),
        );
      },
    );
  }
}