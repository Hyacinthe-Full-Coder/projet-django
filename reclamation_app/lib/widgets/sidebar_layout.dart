import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';

// MISE EN PAGE AVEC BARRE LATÉRALE DE NAVIGATION (NavigationRail)
// Alternative à AppDrawer pour les écrans larges (tablettes, desktop)
class SidebarLayout extends StatelessWidget {
  final String role;
  final String name;
  final int selectedIndex;
  final Function(int) onIndexChanged;
  final Widget body;

  const SidebarLayout({
    super.key,
    required this.role,
    required this.name,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.body,
  });

  // DÉCONNEXION
  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // CONSTRUCTION DES DESTINATIONS DE NAVIGATION SELON LE RÔLE
  List<NavigationRailDestination> _getDestinations() {
    final destinations = [
      const NavigationRailDestination(
        icon: Icon(Icons.dashboard),
        label: Text('Dashboard'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.list),
        label: Text('Tickets'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.bar_chart),
        label: Text('Stats'),
      ),
    ];

    // ADMIN : AJOUT DE L'ASSIGNATION DES TICKETS
    if (role == 'ADMIN') {
      destinations.insert(
        2,
        const NavigationRailDestination(
          icon: Icon(Icons.assignment),
          label: Text('Assigner'),
        ),
      );
    }

    return destinations;
  }

  // CONSTRUCTION DE L'INTERFACE
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BARRE D'APPLICATION
      appBar: AppBar(
        title: Text('$role • $name'),
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      
      // CORPS PRINCIPAL (BARRE LATÉRALE + CONTENU)
      body: Row(
        children: [
          // BARRE DE NAVIGATION LATÉRALE
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onIndexChanged,
            labelType: NavigationRailLabelType.all,
            backgroundColor: const Color(0xFF006743),
            indicatorColor: Colors.white,
            selectedIconTheme: const IconThemeData(color: Color(0xFF006743)),
            selectedLabelTextStyle: const TextStyle(color: Colors.white),
            unselectedIconTheme: const IconThemeData(color: Colors.white70),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
            destinations: _getDestinations(),
          ),
          
          // CONTENU PRINCIPAL
          Expanded(child: body),
        ],
      ),
    );
  }
}