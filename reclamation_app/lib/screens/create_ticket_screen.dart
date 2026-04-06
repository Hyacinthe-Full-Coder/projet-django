import 'package:flutter/material.dart';
import '../services/ticket_service.dart';

// ÉCRAN DE CRÉATION DE TICKET (CITOYEN/TECHNICIEN)
class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  
  // CONTRÔLEURS DE FORMULAIRE
  final _formKey = GlobalKey<FormState>();
  final _titreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  
  // DONNÉES DU TICKET
  String _type = 'INCIDENT';
  String _priorite = 'NORMALE';
  bool _loading = false;
  final _service = TicketService();

  // OPTIONS PRÉDÉFINIES
  static const _types = ['INCIDENT', 'RECLAMATION', 'DEMANDE'];
  static const _priorites = ['BASSE', 'NORMALE', 'HAUTE', 'CRITIQUE'];

  // SOUMISSION DU FORMULAIRE
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket créé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  // CONSTRUCTION DE L'INTERFACE
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BARRE D'APPLICATION
      appBar: AppBar(
        title: const Text('Nouveau ticket'),
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
      ),
      
      // CORPS PRINCIPAL
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // CHAMP TITRE
              TextFormField(
                controller: _titreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Titre *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 16),
              
              // CHAMP DESCRIPTION
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 16),
              
              // MENU DÉROULANT TYPE DE TICKET
              DropdownButtonFormField<String>(
                value: _type,
                items: _types
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
                decoration: const InputDecoration(
                  labelText: 'Type de ticket',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 16),
              
              // MENU DÉROULANT PRIORITÉ
              DropdownButtonFormField<String>(
                value: _priorite,
                decoration: const InputDecoration(
                  labelText: 'Priorité',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                items: _priorites
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _priorite = v!),
              ),
              const SizedBox(height: 28),
              
              // BOUTON DE SOUMISSION
              ElevatedButton.icon(
                onPressed: _loading ? null : _soumettre,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _loading ? 'Envoi...' : 'Soumettre le ticket',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006743),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}