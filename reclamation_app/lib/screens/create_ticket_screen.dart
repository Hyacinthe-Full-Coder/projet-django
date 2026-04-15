import 'package:flutter/material.dart';
import '../services/ticket_service.dart';

// ÉCRAN DE CRÉATION DE TICKET (CITOYEN)
class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _type = 'INCIDENT';
  String _priorite = 'NORMALE';
  bool _loading = false;
  final _service = TicketService();

  static const _types = ['INCIDENT', 'RECLAMATION', 'DEMANDE'];
  static const _priorites = ['BASSE', 'NORMALE', 'HAUTE', 'CRITIQUE'];

  static const _typeIcons = {
    'INCIDENT': Icons.warning_amber_rounded,
    'RECLAMATION': Icons.receipt_long,
    'DEMANDE': Icons.help_outline,
  };

  static const _priorityLabels = {
    'BASSE': 'Basse',
    'NORMALE': 'Normale',
    'HAUTE': 'Haute',
    'CRITIQUE': 'Critique',
  };

  @override
  void dispose() {
    _titreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _soumettre() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await _service.creerTicket({
        'titre': _titreCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'type_ticket': _type,
        'priorite': _priorite,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Votre demande a bien été envoyée.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'envoi : $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildTypeCard(String type) {
    final selected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF6EF) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? const Color(0xFF006743) : const Color(0xFFE0E0E0),
              width: selected ? 1.8 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                _typeIcons[type],
                size: 26,
                color: selected ? const Color(0xFF006743) : const Color(0xFF616161),
              ),
              const SizedBox(height: 12),
              Text(
                type,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? const Color(0xFF006743) : const Color(0xFF424242),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityCard(String priority) {
    final selected = _priorite == priority;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priorite = priority),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF6EF) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? const Color(0xFF006743) : const Color(0xFFE0E0E0),
              width: selected ? 1.8 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _priorityLabels[priority]!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? const Color(0xFF006743) : const Color(0xFF424242),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF37474F),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F2),
      appBar: AppBar(
        title: const Text('Créer une demande'),
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nouvelle demande',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263238),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choisissez le type de ticket, précisez son objet puis décrivez votre problème.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF546E7A),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Type de ticket',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF263238),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: _types.map((type) => _buildTypeCard(type)).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionTitle('Objet du ticket'),
                    TextFormField(
                      controller: _titreCtrl,
                      decoration: InputDecoration(
                        hintText: 'Titre de demande',
                        filled: true,
                        fillColor: const Color(0xFFF7FAF7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez préciser l\'objet du ticket.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    _sectionTitle('Niveau d\'urgence'),
                    Row(
                      children: _priorites.map((priority) => _buildPriorityCard(priority)).toList(),
                    ),
                    const SizedBox(height: 18),
                    _sectionTitle('Description détaillée'),
                    TextFormField(
                      controller: _descCtrl,
                      decoration: InputDecoration(
                        hintText: 'Décrivez le problème avec précision...',
                        filled: true,
                        fillColor: const Color(0xFFF7FAF7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        alignLabelWithHint: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                      ),
                      maxLines: 6,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez décrire le problème.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loading ? null : _soumettre,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(
                _loading ? 'Envoi...' : 'Envoyer ma demande',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006743),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
