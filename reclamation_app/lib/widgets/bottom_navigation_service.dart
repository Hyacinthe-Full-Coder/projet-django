
import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';

// BARRE DE NAVIGATION AU FOOTER
// Affiche les options de navigation selon le rôle de l'utilisateur (ADMIN, TECHNICIEN, CITOYEN)
class BottomNavigationService extends StatelessWidget {
  final String role;
  final int selectedIndex;
  final Function(int) onNavigate;

  const BottomNavigationService({
    super.key,
    required this.role,
    required this.selectedIndex,
    required this.onNavigate,
  });

  // CONSTRUCTION DES ITEMS DE NAVIGATION SELON LE RÔLE
  List<BottomNavigationBarItem> _getBottomItems() {
    if (role == 'ADMIN') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Tickets',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Assigner',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_add),
          label: 'Utilisateurs',
        ),
      ];
    } else if (role == 'TECHNICIEN') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Tickets',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
      ];
    } else if (role == 'CITOYEN') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Mes Tickets',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle),
          label: 'Créer',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final items = _getBottomItems();
    
    return BottomAppBar(
      color: const Color(0xFF006743),
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...items.asMap().entries.map((entry) {
            int index = entry.key;
            BottomNavigationBarItem item = entry.value;
            bool isSelected = index == selectedIndex;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onNavigate(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  color: isSelected 
                      ? Colors.white.withValues(alpha: 0.1) 
                      : Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconTheme(
                        data: IconThemeData(
                          color: isSelected ? Colors.white : Colors.white70,
                          size: 24,
                        ),
                        child: item.icon,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          
          // BOUTON DÉCONNEXION
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _logout(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.logout,
                      color: Colors.white70,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Quitter',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
}
