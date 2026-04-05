import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/technicien_dashboard_screen.dart';
import '../screens/ticket_list_screen.dart';
import '../screens/assign_tickets_screen.dart';
import '../screens/create_user_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/login_screen.dart';

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
            UserAccountsDrawerHeader(
              accountName: Text(name),
              accountEmail: Text(role),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF006743)),
              ),
              decoration: const BoxDecoration(color: Color(0xFF006743)),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                if (role == 'ADMIN') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const TechnicienDashboardScreen()),
                  );
                }
              },
            ),
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
            if (role == 'ADMIN') ...[
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
            ],
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
            const Spacer(),
            const Divider(),
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
}
