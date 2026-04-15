import 'package:flutter/material.dart';
import '../services/ticket_service.dart';
import '../models/ticket.dart';
import '../widgets/simple_pie_chart.dart';

// ÉCRAN DES STATISTIQUES
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  
  // SERVICES ET DONNÉES
  final TicketService _ticketService = TicketService();
  late Future<List<Ticket>> _futureTickets;
  Map<String, int> _stats = {};

  // INITIALISATION
  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  // CHARGEMENT DES STATISTIQUES
  Future<void> _loadStatistics() async {
    _futureTickets = _ticketService.listerTickets();
    final tickets = await _futureTickets;

    // CALCUL DES STATISTIQUES
    final stats = <String, int>{
      'total': tickets.length,
      'ouverts': tickets.where((t) => t.status == 'OUVERT').length,
      'en_cours': tickets.where((t) => t.status == 'EN_COURS').length,
      'resolus': tickets.where((t) => t.status == 'RESOLU').length,
      'clos': tickets.where((t) => t.status == 'CLOS').length,
      'incidents': tickets.where((t) => t.type == 'INCIDENT').length,
      'reclamations': tickets.where((t) => t.type == 'RECLAMATION').length,
      'demandes': tickets.where((t) => t.type == 'DEMANDE').length,
    };

    setState(() {
      _stats = stats;
    });
  }

  // CONSTRUCTION DE L'INTERFACE
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BARRE D'APPLICATION
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
      ),
      
      // CORPS PRINCIPAL
      body: FutureBuilder<List<Ticket>>(
        future: _futureTickets,
        builder: (context, snapshot) {
          
          // ÉTAT CHARGEMENT
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // ÉTAT ERREUR
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erreur: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadStatistics,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          // AFFICHAGE DES STATISTIQUES
          return RefreshIndicator(
            onRefresh: _loadStatistics,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // SECTION PAR STATUT
                const Text(
                  'Résumé des Tickets',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                // GRILLE 2x2 DES CARTES STATUT - ALIGNÉES
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.3,
                  children: [
                    _buildStatCardCompact(
                      'Total',
                      _stats['total']?.toString() ?? '0',
                      Icons.confirmation_number,
                      Colors.blue,
                    ),
                    _buildStatCardCompact(
                      'En cours',
                      _stats['en_cours']?.toString() ?? '0',
                      Icons.work,
                      Colors.orange,
                    ),
                    _buildStatCardCompact(
                      'Résolus',
                      _stats['resolus']?.toString() ?? '0',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildStatCardCompact(
                      'Clos',
                      _stats['clos']?.toString() ?? '0',
                      Icons.archive,
                      Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // GRAPHIQUE CAMEMBERT PAR STATUT
                const Text(
                  'Distribution par statut',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SimplePieChart(
                  title: 'Distribution par statut',
                  data: [
                    PieChartData(label: 'Ouverts', value: _stats['ouverts'] ?? 0, color: Colors.orange),
                    PieChartData(label: 'En cours', value: _stats['en_cours'] ?? 0, color: Colors.blue),
                    PieChartData(label: 'Résolus', value: _stats['resolus'] ?? 0, color: Colors.green),
                    PieChartData(label: 'Clos', value: _stats['clos'] ?? 0, color: Colors.grey),
                  ],
                  size: 200,
                ),
                const SizedBox(height: 24),
                
                // SECTION PAR TYPE
                const Text(
                  'Distribution par Type',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                // GRILLE 3 COLONNES POUR LES TYPES
                GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.2,
                  children: [
                    _buildStatCardCompact(
                      'Incidents',
                      _stats['incidents']?.toString() ?? '0',
                      Icons.bug_report,
                      Colors.red,
                    ),
                    _buildStatCardCompact(
                      'Réclamations',
                      _stats['reclamations']?.toString() ?? '0',
                      Icons.feedback,
                      Colors.orange,
                    ),
                    _buildStatCardCompact(
                      'Demandes',
                      _stats['demandes']?.toString() ?? '0',
                      Icons.help,
                      Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // GRAPHIQUE CAMEMBERT PAR TYPE
                SimplePieChart(
                  title: 'Distribution par type',
                  data: [
                    PieChartData(label: 'Incidents', value: _stats['incidents'] ?? 0, color: Colors.red),
                    PieChartData(label: 'Réclamations', value: _stats['reclamations'] ?? 0, color: Colors.orange),
                    PieChartData(label: 'Demandes', value: _stats['demandes'] ?? 0, color: Colors.purple),
                  ],
                  size: 150,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // CARTE STATISTIQUE GÉNÉRIQUE
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // ICÔNE COLORÉE
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            
            // TITRE ET VALEUR
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CARTE STATISTIQUE COMPACTE POUR GRILLE
  Widget _buildStatCardCompact(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ICÔNE COLORÉE
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            
            // VALEUR
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            // TITRE
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}