import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Le service d'authentification pour gérer les opérations liées à l'utilisateur telles que la connexion, l'inscription, la création d'utilisateur, etc. 
class AuthService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

// La méthode de connexion qui envoie une requête POST à l'API pour authentifier l'utilisateur. Si la connexion est réussie, les tokens d'accès et de rafraîchissement sont stockés dans les SharedPreferences. En cas d'échec, un message d'erreur approprié est retourné.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

// Si la connexion est réussie, les tokens sont stockés et une réponse de succès est retournée.
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['access']);
      await prefs.setString('refresh_token', data['refresh']);
      return {'success': true};
    }

// En cas d'échec, le code essaie de décoder la réponse pour extraire un message d'erreur spécifique. Si cela échoue, un message d'erreur générique est retourné.
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

// La méthode d'inscription qui envoie une requête POST à l'API pour créer un nouvel utilisateur. Si l'inscription est réussie, une réponse de succès est retournée. En cas d'échec, le code essaie de décoder la réponse pour extraire un message d'erreur spécifique. Si cela échoue, un message d'erreur générique est retourné.
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

// Si l'inscription est réussie, une réponse de succès est retournée.
    if (response.statusCode == 201) {
      return {'success': true, 'message': 'Inscriptin réussie!'};
    }

// En cas d'échec, le code essaie de décoder la réponse pour extraire un message d'erreur spécifique. Si cela échoue, un message d'erreur générique est retourné.
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

// La méthode de création d'utilisateur qui envoie une requête POST à l'API pour créer un nouvel utilisateur. Cette méthode nécessite que l'utilisateur soit authentifié, car elle utilise le token d'accès pour autoriser la requête. Si la création est réussie, une réponse de succès est retournée. En cas d'échec, le code essaie de décoder la réponse pour extraire un message d'erreur spécifique. Si cela échoue, un message d'erreur générique est retourné.
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

// Envoie la requête POST pour créer un nouvel utilisateur avec les informations fournies et le token d'accès pour l'autorisation.
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

// Si la création est réussie, une réponse de succès est retournée.
    if (response.statusCode == 201) {
      return {'success': true, 'message': 'Utilisateur créé avec succès!'};
    }

// En cas d'échec, le code essaie de décoder la réponse pour extraire un message d'erreur spécifique. Si cela échoue, un message d'erreur générique est retourné.
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

// La méthode pour récupérer les données du tableau de bord qui envoie une requête GET à l'API. Cette méthode nécessite que l'utilisateur soit authentifié, car elle utilise le token d'accès pour autoriser la requête. Si la requête est réussie, les données du tableau de bord sont retournées. En cas d'échec, null est retourné.
  Future<Map<String, dynamic>?> getDashboard() async {
    final token = await getAccessToken();
    if (token == null) return null;

// Envoie la requête GET pour récupérer les données du tableau de bord avec le token d'accès pour l'autorisation.
    final response = await http.get(
      Uri.parse('$baseUrl/tickets/dashboard/'),
      headers: {'Authorization': 'Bearer $token'},
    );

// Si la requête est réussie, les données du tableau de bord sont retournées.
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

// La méthode de déconnexion qui supprime les tokens d'accès et de rafraîchissement des SharedPreferences, ce qui déconnecte l'utilisateur de l'application.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

// La méthode pour récupérer le token d'accès stocké dans les SharedPreferences. Si aucun token n'est trouvé, null est retourné.
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

// La méthode pour vérifier si l'utilisateur est actuellement connecté en vérifiant la présence d'un token d'accès valide dans les SharedPreferences. Si un token est trouvé et n'est pas vide, true est retourné, sinon false est retourné.
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

// La méthode pour récupérer les informations du profil de l'utilisateur en envoyant une requête GET à l'API. Cette méthode nécessite que l'utilisateur soit authentifié, car elle utilise le token d'accès pour autoriser la requête. Si la requête est réussie, les données du profil de l'utilisateur sont retournées. En cas d'échec, null est retourné.
  Future<Map<String, dynamic>?> getUserProfile() async {
    final token = await getAccessToken();
    if (token == null) return null;

// Envoie la requête GET pour récupérer les informations du profil de l'utilisateur avec le token d'accès pour l'autorisation.
    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile/'),
      headers: {'Authorization': 'Bearer $token'},
    );

// Si la requête est réussie, les données du profil de l'utilisateur sont retournées.
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
