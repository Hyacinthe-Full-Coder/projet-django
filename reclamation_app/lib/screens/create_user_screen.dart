import 'package:flutter/material.dart';
import '../services/auth_service.dart';

// ÉCRAN DE CRÉATION D'UTILISATEUR (ADMIN)
class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({Key? key}) : super(key: key);

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  // CONTRÔLEURS DE FORMULAIRE
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _telephoneCtrl = TextEditingController();
  final _authService = AuthService();

  // ÉTATS DE L'INTERFACE
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _erreur;
  String? _success;
  String _selectedRole = 'TECHNICIEN';

  // CRÉATION DE L'UTILISATEUR
  Future<void> _createUser() async {
    // VALIDATION DU FORMULAIRE
    if (!_formKey.currentState!.validate()) return;

    // VÉRIFICATION MOT DE PASSE
    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      setState(() => _erreur = 'Les mots de passe ne correspondent pas');
      return;
    }

    // RÉINITIALISATION DES MESSAGES
    setState(() {
      _loading = true;
      _erreur = null;
      _success = null;
    });

    try {
      // APPEL API DE CRÉATION
      final result = await _authService.createUser(
        _emailCtrl.text.trim(),
        _usernameCtrl.text.trim(),
        _passwordCtrl.text,
        _firstNameCtrl.text.trim(),
        _lastNameCtrl.text.trim(),
        _selectedRole,
        _telephoneCtrl.text.trim(),
      );

      if (result['success'] == true) {
        setState(() => _success = result['message']);

        // RÉINITIALISATION DU FORMULAIRE
        _formKey.currentState!.reset();
        _emailCtrl.clear();
        _usernameCtrl.clear();
        _passwordCtrl.clear();
        _confirmPasswordCtrl.clear();
        _firstNameCtrl.clear();
        _lastNameCtrl.clear();
        _telephoneCtrl.clear();
        setState(() => _selectedRole = 'TECHNICIEN');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']!),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _erreur = result['message'] ?? 'Erreur de création');
      }
    } catch (e) {
      setState(() => _erreur = 'Erreur réseau : ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // CONSTRUCTION DE L'INTERFACE
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BARRE D'APPLICATION
      appBar: AppBar(
        backgroundColor: const Color(0xFF006743),
        foregroundColor: Colors.white,
        title: const Text('Créer Utilisateur'),
      ),

      // CORPS PRINCIPAL
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // EN-TÊTE
                    const Icon(
                      Icons.person_add,
                      size: 50,
                      color: Color(0xFF006743),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Créer un nouvel utilisateur',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006743),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // SECTION RÔLE
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rôle *',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButton<String>(
                            value: _selectedRole,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: 'TECHNICIEN',
                                child: Text('Technicien Support'),
                              ),
                              DropdownMenuItem(
                                value: 'ADMIN',
                                child: Text('Administrateur'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => _selectedRole = value!);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // CHAMP EMAIL
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: InputDecoration(
                        labelText: 'Email *',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email requis';
                        }
                        if (!value.contains('@')) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // CHAMP NOM D'UTILISATEUR
                    TextFormField(
                      controller: _usernameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nom d\'utilisateur *',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nom d\'utilisateur requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // CHAMP PRÉNOM
                    TextFormField(
                      controller: _firstNameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Prénom *',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Prénom requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // CHAMP NOM
                    TextFormField(
                      controller: _lastNameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nom *',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nom requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // CHAMP TÉLÉPHONE (OPTIONNEL)
                    TextFormField(
                      controller: _telephoneCtrl,
                      decoration: InputDecoration(
                        labelText: 'Téléphone (optionnel)',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // CHAMP MOT DE PASSE
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe *',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mot de passe requis';
                        }
                        if (value.length < 6) {
                          return 'Minimum 6 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // CHAMP CONFIRMATION MOT DE PASSE
                    TextFormField(
                      controller: _confirmPasswordCtrl,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirmer le mot de passe *',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => _obscureConfirm = !_obscureConfirm);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirmation requise';
                        }
                        return null;
                      },
                    ),

                    // AFFICHAGE ERREUR
                    if (_erreur != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Text(
                          _erreur!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // BOUTON CRÉATION
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _createUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006743),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Créer l\'utilisateur',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // LIBÉRATION DES CONTRÔLEURS
  @override
  void dispose() {
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _telephoneCtrl.dispose();
    super.dispose();
  }
}
