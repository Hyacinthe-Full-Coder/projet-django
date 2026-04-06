import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// SERVICE D'AUTHENTIFICATION
// Gère les opérations liées à l'utilisateur : connexion, inscription, création, profil, etc.
class AuthService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  // CONNEXION UTILISATEUR
  // Envoie une requête POST à l'API pour authentifier l'utilisateur.
  // Stocke les tokens JWT en cas de succès.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    // SUCCÈS : stockage des tokens
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['access']);
      await prefs.setString('refresh_token', data['refresh']);
      return {'success': true};
    }

    // ÉCHEC : extraction du message d'erreur
    try {
      final data = jsonDecode(response.body);
      final message =
          data['detail'] ??
          data['message'] ??
          'Email ou mot de passe incorrect.';
      return {'success': false, 'message': message};
    } catch (_) {
      return {'success': false, 'message': 'Email ou mot de passe incorrect.'};
    }
  }

  // INSCRIPTION UTILISATEUR (CITOYEN)
  // Envoie une requête POST pour créer un nouveau compte citoyen.
  Future<Map<String, dynamic>> register(
    String email,
    String username,
    String password,
    String firstName,
    String lastName,
    String telephone,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'username': username,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'telephone': telephone,
      }),
    );

    // SUCCÈS
    if (response.statusCode == 201) {
      return {'success': true, 'message': 'Inscription réussie!'};
    }

    // ÉCHEC : extraction du message d'erreur
    try {
      final data = jsonDecode(response.body);
      String message = 'Erreur lors de l\'inscription';
      if (data is Map) {
        if (data.containsKey('email')) message = data['email'][0];
        if (data.containsKey('username')) message = data['username'][0];
      }
      return {'success': false, 'message': message};
    } catch (_) {
      return {'success': false, 'message': 'Erreur lors de l\'inscription'};
    }
  }

  // CRÉATION D'UTILISATEUR PAR ADMIN
  // Envoie une requête POST pour créer un technicien ou admin.
  // Nécessite un token d'authentification.
  Future<Map<String, dynamic>> createUser(
    String email,
    String username,
    String password,
    String firstName,
    String lastName,
    String role,
    String telephone,
  ) async {
    final token = await getAccessToken();
    if (token == null) {
      return {'success': false, 'message': 'Non authentifié'};
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/create-user/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'email': email,
        'username': username,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'role': role,
        'telephone': telephone,
      }),
    );

    // SUCCÈS
    if (response.statusCode == 201) {
      return {'success': true, 'message': 'Utilisateur créé avec succès!'};
    }

    // ÉCHEC : extraction du message d'erreur
    try {
      final data = jsonDecode(response.body);
      String message = 'Erreur lors de la création';
      if (data is Map) {
        if (data.containsKey('detail')) message = data['detail'];
        if (data.containsKey('email')) message = data['email'][0];
      }
      return {'success': false, 'message': message};
    } catch (_) {
      return {'success': false, 'message': 'Erreur lors de la création'};
    }
  }

  // RÉCUPÉRATION DU TABLEAU DE BORD
  // Envoie une requête GET pour obtenir les statistiques selon le rôle.
  // Nécessite un token d'authentification.
  Future<Map<String, dynamic>?> getDashboard() async {
    final token = await getAccessToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/tickets/dashboard/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // DÉCONNEXION
  // Supprime les tokens stockés localement.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // RÉCUPÉRATION DU TOKEN D'ACCÈS
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // VÉRIFICATION DE L'ÉTAT DE CONNEXION
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // RÉCUPÉRATION DU PROFIL UTILISATEUR
  // Envoie une requête GET pour obtenir les infos de l'utilisateur connecté.
  // Nécessite un token d'authentification.
  Future<Map<String, dynamic>?> getUserProfile() async {
    final token = await getAccessToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}