import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

// SERVICE DE GESTION DES NOTIFICATIONS
class NotificationService {
  final String baseUrl = ApiConfig.baseUrl;
  final AuthService _authService = AuthService();

  // RÉCUPÉRER LES NOTIFICATIONS DE L'UTILISATEUR
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final token = await _authService.getAccessToken();
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Erreur lors de la récupération des notifications');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // COMPTER LES NOTIFICATIONS NON LUES
  Future<int> getUnreadCount() async {
    try {
      final token = await _authService.getAccessToken();
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/compter_non_lues/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['non_lues'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  // MARQUER UNE NOTIFICATION COMME LUE
  Future<void> markAsRead(int notificationId) async {
    try {
      final token = await _authService.getAccessToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/$notificationId/marquer_lue/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors du marquage de la notification');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // MARQUER TOUTES LES NOTIFICATIONS COMME LUES
  Future<void> markAllAsRead() async {
    try {
      final token = await _authService.getAccessToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/marquer_toutes_lues/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors du marquage des notifications');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // SUPPRIMER UNE NOTIFICATION
  Future<void> deleteNotification(int notificationId) async {
    try {
      final token = await _authService.getAccessToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/notifications/$notificationId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 204) {
        throw Exception('Erreur lors de la suppression de la notification');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // LIBÉRER LES RESSOURCES
  void dispose() {
    // Rien à nettoyer pour le moment
  }
}