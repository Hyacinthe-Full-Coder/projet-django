import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

// SERVICE D'AUTHENTIFICATION
// Gère les opérations liées à l'utilisateur : connexion, inscription, création, profil, etc.
class AuthService {
  late final http.Client _client;

  AuthService() {
    // Client HTTP avec timeouts
    _client = http.Client();
  }

  String get baseUrl => ApiConfig.baseUrl;

  // Wrapper pour les requêtes avec gestion des timeouts
  Future<http.Response> _postWithTimeout(
    Uri uri, {
    required Map<String, String> headers,
    required String body,
  }) async {
    try {
      final response = await _client
          .post(uri, headers: headers, body: body)
          .timeout(
            const Duration(
              seconds: ApiConfig.connectTimeout,
            ),
            onTimeout: () => throw TimeoutException(
              'Connexion dépassée. Vérifiez votre connexion internet et l\'adresse du serveur.',
            ),
          );
      return response;
    } on TimeoutException catch (e) {
      throw Exception('⏱ ${e.message}');
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<http.Response> _getWithTimeout(
    Uri uri, {
    required Map<String, String> headers,
  }) async {
    try {
      final response = await _client
          .get(uri, headers: headers)
          .timeout(
            const Duration(
              seconds: ApiConfig.receiveTimeout,
            ),
            onTimeout: () => throw TimeoutException(
              'Connexion dépassée. Vérifiez votre connexion internet.',
            ),
          );
      return response;
    } on TimeoutException catch (e) {
      throw Exception('⏱ ${e.message}');
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // CONNEXION UTILISATEUR
  // Envoie une requête POST à l'API pour authentifier l'utilisateur.
  // Stocke les tokens JWT en cas de succès.
  // Avec timeout et gestion d'erreur réseau
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl${ApiConfig.authLogin}'),
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

      // ERREUR 401 ou 400
      if (response.statusCode == 401 || response.statusCode == 400) {
        try {
          final data = jsonDecode(response.body);
          final message = data['detail'] ??
              data['message'] ??
              'Email ou mot de passe incorrect.';
          return {'success': false, 'message': message};
        } catch (_) {
          return {
            'success': false,
            'message': 'Email ou mot de passe incorrect.'
          };
        }
      }

      // AUTRES ERREURS
      return {
        'success': false,
        'message':
            'Erreur serveur (${response.statusCode}). Contactez l\'administrateur.'
      };
    } on Exception catch (e) {
      return {'success': false, 'message': e.toString()};
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
    try {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl${ApiConfig.authRegister}'),
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
    } on Exception catch (e) {
      return {'success': false, 'message': e.toString()};
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
    try {
      final token = await getAccessToken();
      if (token == null) return null;

      final response = await _getWithTimeout(
        Uri.parse('$baseUrl${ApiConfig.authProfile}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      // Si token expiré (401), tenter de le rafraîchir
      if (response.statusCode == 401) {
        // TODO: Implémenter refresh token
        return null;
      }
      return null;
    } on Exception catch (e) {
      print('Erreur profil: $e');
      return null;
    }
  }
}