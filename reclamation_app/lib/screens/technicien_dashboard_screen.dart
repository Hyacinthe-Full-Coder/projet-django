import 'dart:math';

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/bottom_navigation_service.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

// ÉCRAN TABLEAU DE BORD TECHNICIEN
class TechnicienDashboardScreen extends StatefulWidget {
  const TechnicienDashboardScreen({super.key});

  @override
  State<TechnicienDashboardScreen> createState() =>
      _TechnicienDashboardScreenState();
}

class _TechnicienDashboardScreenState extends State<TechnicienDashboardScreen> {
  // SERVICES ET DONNÉES
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  int _selectedIndex = 0; // 0: Dashboard, 1: Liste des tickets

  // INITIALISATION
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // CHARGEMENT DES DONNÉES
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _authService.getUserProfile();
      final dashboard = await _authService.getDashboard();
      setState(() {
        _userProfile = profile;
        _dashboardData = dashboard;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // DÉCONNEXION
  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 1:
        return 'Mes Tickets';
      case 2:
        return 'Notifications';
      default:
        return 'Dashboard Technicien';
    }
  }

  // CONSTRUCTION DE L'INTERFACE
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      // BARRE D'APPLICATION
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Mon profil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),

      // CORPS PRINCIPAL (SWITCH ENTRE VUES)
      body: _buildViewByIndex(_selectedIndex),

      // FOOTER DE NAVIGATION
      bottomNavigationBar: BottomNavigationService(
        role: 'TECHNICIEN',
        selectedIndex: _selectedIndex,
        onNavigate: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }

  // CONSTRUCTION DE LA VUE SELON L'INDEX
  Widget _buildViewByIndex(int index) {
    switch (index) {
      case 0:
        // DASHBOARD
        return _buildDashboardView();
      case 1:
        // MES TICKETS
        return _buildMyTicketsView();
      case 2:
        // NOTIFICATIONS
        return NotificationsScreen(
          role: 'TECHNICIEN',
          name: '${_userProfile?['first_name']} ${_userProfile?['last_name']}',
          embedded: true,
        );
      default:
        return const Center(child: Text('Vue non trouvée'));
    }
  }

  // VUE TABLEAU DE BORD
  Widget _buildDashboardView() {
    final myTickets =
        (_dashboardData!['my_tickets'] as Map<String, dynamic>?) ?? {};

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // SECTION BIENVENUE
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006743),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.support_agent,
                        color: Colors.white,
                        size: 40,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bienvenue Technicien',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_userProfile?['first_name']} ${_userProfile?['last_name']}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // SECTION STATISTIQUES
                if (_dashboardData != null) ...[
                  // TOTAL TICKETS ASSIGNÉS
                  Center(
                    child: _buildStatCard(
                      'Total Tickets',
                      (_dashboardData!['total_tickets_assignes'] ?? 0)
                          .toString(),
                      Icons.event_note,
                      Colors.indigo,
                      width: 140,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // TICKETS PAR STATUT
                  const Text(
                    'Mes Tickets par Statut',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Column(
                      children: [
                        _buildStatCard(
                          'En cours',
                          (myTickets['EN_COURS'] ?? 0).toString(),
                          Icons.work_outline,
                          Colors.blue,
                          width: 140,
                        ),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          'Résolus',
                          (myTickets['RESOLU'] ?? 0).toString(),
                          Icons.check_circle,
                          Colors.green,
                          width: 140,
                        ),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          'Clos',
                          (myTickets['CLOS'] ?? 0).toString(),
                          Icons.archive,
                          Colors.grey,
                          width: 140,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // GRAPHIQUES STATISTIQUES
                  _buildStatusCharts(myTickets),
                  const SizedBox(height: 24),

                  // TICKETS RÉCENTS
                  const Text(
                    'Tickets Récents',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  if (_dashboardData!['recent_tickets'] != null &&
                      (_dashboardData!['recent_tickets'] as List).isNotEmpty)
                    _buildRecentTickets(_dashboardData!['recent_tickets'])
                  else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Aucun ticket récent'),
                      ),
                    ),
                ] else
                  const Center(
                    child: Text('Erreur lors du chargement des données'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // CARTE STATISTIQUE GÉNÉRIQUE
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    double width = double.infinity,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // LISTE DES TICKETS RÉCENTS
  Widget _buildRecentTickets(List<dynamic> tickets) {
    return Column(
      children: tickets.map((ticket) {
        final statusColor = _getStatusColor(ticket['statut']);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LIGNE TITRE + STATUT
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ticket['titre'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ticket['statut'] ?? '',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // LIGNE TYPE + PRIORITÉ
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Type: ${ticket['type_ticket'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'Priorité: ${ticket['priorite'] ?? ''}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusCharts(Map<String, dynamic> myTickets) {
    final Map<String, int> data = {
      'Ouvert': myTickets['OUVERT'] as int? ?? 0,
      'En cours': myTickets['EN_COURS'] as int? ?? 0,
      'Résolus': myTickets['RESOLU'] as int? ?? 0,
      'Clos': myTickets['CLOS'] as int? ?? 0,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Répartition des tickets',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            return Wrap(
              runSpacing: 16,
              spacing: 16,
              alignment: WrapAlignment.center,
              children: [
                SizedBox(
                  width: min(constraints.maxWidth, 320),
                  height: 320,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Diagramme Circulaire',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: TicketStatusPieChart(data: data),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: min(constraints.maxWidth, 320),
                  height: 320,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Diagramme en Barre',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: TicketStatusBarChart(data: data),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // VUE MES TICKETS
  Widget _buildMyTicketsView() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tickets à Traiter',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // AFFICHAGE DES TICKETS RÉCENTS
            if (_dashboardData?['recent_tickets'] != null &&
                (_dashboardData!['recent_tickets'] as List).isNotEmpty)
              Column(
                children: List.generate(
                  (_dashboardData!['recent_tickets'] as List).length,
                  (index) {
                    final ticket = (_dashboardData!['recent_tickets'] as List)[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildSimpleTicketCard(ticket),
                    );
                  },
                ),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun ticket pour le moment',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // CARTE STATISTIQUE COMPACTE
  Widget _buildStatCardCompact(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // CARTE TICKET SIMPLE (SANS TICKET CARD)
  Widget _buildSimpleTicketCard(Map<String, dynamic> ticket) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITRE + STATUT
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    ticket['titre'] ?? 'Sans titre',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(ticket['statut'] ?? ''),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ticket['statut'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // DESCRIPTION
            Text(
              ticket['description'] ?? '',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // TYPE + PRIORITÉ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Type: ${ticket['type_ticket'] ?? ''}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'Priorité: ${ticket['priorite'] ?? ''}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // COULEUR SELON LE STATUT
  Color _getStatusColor(String status) {
    switch (status) {
      case 'OUVERT':
        return Colors.orange;
      case 'EN_COURS':
        return Colors.blue;
      case 'RESOLU':
        return Colors.green;
      case 'CLOS':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

class TicketStatusPieChart extends StatelessWidget {
  final Map<String, int> data;

  const TicketStatusPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold<int>(0, (sum, value) => sum + value);
    return total == 0
        ? const Center(child: Text('Aucune donnée'))
        : Stack(
            children: [
              CustomPaint(
                painter: _TicketStatusPiePainter(data: data),
                child: const SizedBox.expand(),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$total',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Total',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}

class _TicketStatusPiePainter extends CustomPainter {
  final Map<String, int> data;

  _TicketStatusPiePainter({required this.data});

  static const Map<String, Color> _statusColors = {
    'Ouvert': Colors.orange,
    'En cours': Colors.blue,
    'Résolus': Colors.green,
    'Clos': Colors.grey,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.values.fold<int>(0, (sum, value) => sum + value);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.4;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = radius * 0.5;

    double startAngle = -pi / 2;
    data.forEach((label, value) {
      if (value <= 0) return;
      final sweep = 2 * pi * value / total;
      paint.color = _statusColors[label] ?? Colors.grey;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TicketStatusBarChart extends StatelessWidget {
  final Map<String, int> data;

  const TicketStatusBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final maxValue = data.values.fold<int>(0, (max, value) => value > max ? value : max);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: CustomPaint(
              painter: _TicketStatusBarPainter(data: data, maxValue: maxValue),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: data.entries.map((entry) {
            final color = _statusColor(entry.key);
            return Expanded(
              child: Column(
                children: [
                  Container(
                    height: 8,
                    width: 20,
                    color: color,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.key,
                    style: const TextStyle(fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _statusColor(String label) {
    switch (label) {
      case 'Ouvert':
        return Colors.orange;
      case 'En cours':
        return Colors.blue;
      case 'Résolus':
        return Colors.green;
      case 'Clos':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

class _TicketStatusBarPainter extends CustomPainter {
  final Map<String, int> data;
  final int maxValue;

  _TicketStatusBarPainter({required this.data, required this.maxValue});

  static const Map<String, Color> _statusColors = {
    'Ouvert': Colors.orange,
    'En cours': Colors.blue,
    'Résolus': Colors.green,
    'Clos': Colors.grey,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / (data.length * 1.5);
    final spacing = barWidth / 2;
    final baseY = size.height - 16;
    final paint = Paint()..style = PaintingStyle.fill;
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    if (maxValue == 0) {
      final noData = TextPainter(
        text: const TextSpan(
          text: 'Aucune donnée',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width);
      noData.paint(canvas, Offset((size.width - noData.width) / 2, size.height / 2 - noData.height / 2));
      return;
    }

    int index = 0;
    data.forEach((label, value) {
      final left = index * (barWidth + spacing) + spacing / 2;
      final barHeight = (value / maxValue) * (size.height - 40);
      paint.color = _statusColors[label] ?? Colors.grey;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, baseY - barHeight, barWidth, barHeight),
          const Radius.circular(8),
        ),
        paint,
      );

      final valueText = TextPainter(
        text: TextSpan(
          text: value.toString(),
          style: const TextStyle(color: Colors.black, fontSize: 12),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: barWidth + 10);

      final valueX = left + (barWidth - valueText.width) / 2;
      final valueY = baseY - barHeight - valueText.height - 4;
      valueText.paint(canvas, Offset(valueX, valueY));

      index += 1;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
