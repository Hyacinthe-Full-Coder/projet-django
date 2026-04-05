import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket.dart';
import 'auth_service.dart';

class TicketService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/tickets';
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Ticket>> listerTickets({String? status, String? priorite}) async {
    String url = '$baseUrl/';

    final params = <String, String>{};
    if (status != null) params['status'] = status;
    if (priorite != null) params['priorite'] = priorite;
    if (params.isNotEmpty) {
      url += '?' + Uri(queryParameters: params).query;
    }

    final response = await http.get(Uri.parse(url), headers: await _headers());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'] ?? data;
      return results.map((j) => Ticket.fromJson(j)).toList();
    }
    throw Exception('Impossible de charger les tickets');
  }

  Future<Ticket> getTicket(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id/'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return Ticket.fromJson(jsonDecode(response.body));
    }
    throw Exception('Ticket introuvable');
  }

  Future<Ticket> creerTicket(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return Ticket.fromJson(jsonDecode(response.body));
    }
    final body = response.body.isNotEmpty ? response.body : 'aucun contenu';
    throw Exception('Erreur lors de la création du ticket (HTTP ${response.statusCode}) : $body');
  }

  Future<void> changerStatus(int id, String nouveauStatus) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$id/changer_statut/'),
      headers: await _headers(),
      body: jsonEncode({'statut': nouveauStatus}),
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur lors du changement de statut: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> commenter(int ticketId, String contenu) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$ticketId/commenter/'),
      headers: await _headers(),
      body: jsonEncode({'contenu': contenu}),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur lors de l\'ajout du commentaire: ${response.body}');
  }

  Future<void> assignerTicket(int id, {int? technicienId, bool auto = false}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$id/assigner/'),
      headers: await _headers(),
      body: jsonEncode({
        if (technicienId != null) 'technicien_id': technicienId,
        'auto': auto,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de l\'assignation: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> listerTechniciens() async {
    final response = await http.get(
      Uri.parse('${baseUrl.replaceAll('/tickets', '/techniciens/')}'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['results'] ?? data);
    }
    throw Exception('Erreur lors du chargement des techniciens: ${response.body}');
  }
}

