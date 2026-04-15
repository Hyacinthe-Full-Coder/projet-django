import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/ticket.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

// SERVICE DE GESTION DES TICKETS
// Gère toutes les opérations liées aux tickets : création, liste, détails, statut, commentaires, assignation
class TicketService {
  final AuthService _auth = AuthService();
  late final http.Client _client;

  // Cache simple pour éviter les requêtes répétées
  static const Duration _cacheDuration = Duration(minutes: 5);
  Map<int, CachedTicket> _ticketCache = {};
  DateTime _lastListTime = DateTime.now().subtract(const Duration(hours: 1));
  List<Ticket> _cachedList = [];

  TicketService() {
    _client = http.Client();
  }

  String get _baseUrl => ApiConfig.baseUrl;
  String get _ticketsUrl => '$_baseUrl${ApiConfig.ticketsList}';

  // Wrapper pour les requêtes avec gestion des timeouts
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
              seconds: ApiConfig.sendTimeout,
            ),
            onTimeout: () => throw TimeoutException(
              'Envoi dépassé. Vérifiez votre connexion internet.',
            ),
          );
      return response;
    } on TimeoutException catch (e) {
      throw Exception('⏱ ${e.message}');
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<http.Response> _postWithRefresh(
    Uri uri, {
    required Map<String, String> headers,
    required String body,
  }) async {
    final response = await _postWithTimeout(uri, headers: headers, body: body);
    if (response.statusCode != 401) {
      return response;
    }

    final refreshed = await _auth.refreshAccessToken();
    if (!refreshed) {
      return response;
    }

    final token = await _auth.getAccessToken();
    if (token == null) {
      return response;
    }

    final retryHeaders = Map<String, String>.from(headers);
    retryHeaders['Authorization'] = 'Bearer $token';
    return await _postWithTimeout(uri, headers: retryHeaders, body: body);
  }

  Future<http.Response> _patchWithTimeout(
    Uri uri, {
    required Map<String, String> headers,
    required String body,
  }) async {
    try {
      final response = await _client
          .patch(uri, headers: headers, body: body)
          .timeout(
            const Duration(
              seconds: ApiConfig.sendTimeout,
            ),
            onTimeout: () => throw TimeoutException(
              'Modification dépassée. Vérifiez votre connexion internet.',
            ),
          );
      return response;
    } on TimeoutException catch (e) {
      throw Exception('⏱ ${e.message}');
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // CONSTRUCTION DES EN-TÊTES HTTP (AUTHENTIFICATION)
  Future<Map<String, String>> _headers() async {
    final token = await _auth.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // LISTER LES TICKETS (AVEC FILTRES ET CACHE)
  Future<List<Ticket>> listerTickets(
      {String? statut, String? priorite, bool forceRefresh = false}) async {
    // Retourner cache si valide et pas forceRefresh
    if (!forceRefresh &&
        DateTime.now().difference(_lastListTime) < _cacheDuration &&
        _cachedList.isNotEmpty) {
      return _cachedList;
    }

    try {
      String url = _ticketsUrl;

      // CONSTRUCTION DES PARAMÈTRES DE FILTRAGE
      final params = <String, String>{};
      if (statut != null && statut != 'TOUS') params['statut'] = statut;
      if (priorite != null) params['priorite'] = priorite;
      if (params.isNotEmpty) {
        url += '?' + Uri(queryParameters: params).query;
      }

      // REQUÊTE GET
      final response =
          await _getWithTimeout(Uri.parse(url), headers: await _headers());
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['results'] ?? data; // Gère la pagination
        _cachedList = results.map((j) => Ticket.fromJson(j)).toList();
        _lastListTime = DateTime.now();
        return _cachedList;
      }
      throw Exception(
          'Impossible de charger les tickets (${response.statusCode})');
    } catch (_) {
      // Retourner cache même expiré en cas d'erreur
      if (_cachedList.isNotEmpty) return _cachedList;
      rethrow;
    }
  }

  // RÉCUPÉRER UN TICKET PAR ID (AVEC CACHE)
  Future<Ticket> getTicket(int id) async {
    // Vérifier le cache
    if (_ticketCache.containsKey(id)) {
      final cached = _ticketCache[id];
      if (cached != null &&
          DateTime.now().difference(cached.fetchTime) < _cacheDuration) {
        return cached.ticket;
      } else {
        _ticketCache.remove(id); // Ticket expiré
      }
    }

    try {
      final response = await _getWithTimeout(
        Uri.parse('$_ticketsUrl$id/'),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final ticket = Ticket.fromJson(jsonDecode(response.body));
        // Mettre en cache
        _ticketCache[id] = CachedTicket(ticket, DateTime.now());
        return ticket;
      }
      throw Exception('Ticket introuvable (${response.statusCode})');
    } on Exception catch (e) {
      // Retourner cache même expiré en cas d'erreur
      if (_ticketCache.containsKey(id)) {
        final cached = _ticketCache[id];
        if (cached != null) {
          return cached.ticket;
        }
      }
      rethrow;
    }
  }

  // CRÉER UN NOUVEAU TICKET (AVEC TIMEOUT)
  Future<Ticket> creerTicket(Map<String, dynamic> data) async {
    try {
      final response = await _postWithRefresh(
        Uri.parse(_ticketsUrl),
        headers: await _headers(),
        body: jsonEncode(data),
      );
      if (response.statusCode == 201) {
        final ticket = Ticket.fromJson(jsonDecode(response.body));
        // Invalidate list cache
        _lastListTime = DateTime.now().subtract(const Duration(hours: 1));
        return ticket;
      }
      final body = response.body.isNotEmpty ? response.body : 'aucun contenu';
      throw Exception(
          'Erreur lors de la création du ticket (HTTP ${response.statusCode}) : $body');
    } catch (_) {
      rethrow;
    }
  }

  // CHANGER LE STATUT D'UN TICKET (AVEC TIMEOUT)
  Future<void> changerStatus(int id, String nouveauStatus) async {
    try {
      final response = await _patchWithTimeout(
        Uri.parse('$_ticketsUrl$id/changer_statut/'),
        headers: await _headers(),
        body: jsonEncode({'statut': nouveauStatus}),
      );
      if (response.statusCode != 200) {
        throw Exception(
            'Erreur lors du changement de statut: ${response.body}');
      }
      // Invalidate cache
      _ticketCache.remove(id);
      _lastListTime = DateTime.now().subtract(const Duration(hours: 1));
    } on Exception catch (e) {
      rethrow;
    }
  }

  // AJOUTER UN COMMENTAIRE (AVEC TIMEOUT)
  Future<Map<String, dynamic>> commenter(int ticketId, String contenu) async {
    try {
      final response = await _postWithTimeout(
        Uri.parse('$_ticketsUrl$ticketId/commenter/'),
        headers: await _headers(),
        body: jsonEncode({'contenu': contenu}),
      );
      if (response.statusCode == 201) {
        // Invalidate cache
        _ticketCache.remove(ticketId);
        return jsonDecode(response.body);
      }
      throw Exception(
          'Erreur lors de l\'ajout du commentaire: ${response.body}');
    } catch (_) {
      rethrow;
    }
  }

  // ASSIGNER UN TECHNICIEN À UN TICKET (AVEC TIMEOUT)
  Future<void> assignerTicket(int id,
      {int? technicienId, bool auto = false}) async {
    try {
      final response = await _postWithTimeout(
        Uri.parse('$_ticketsUrl$id/assigner/'),
        headers: await _headers(),
        body: jsonEncode({
          if (technicienId != null) 'technicien_id': technicienId,
          'auto': auto,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de l\'assignation: ${response.body}');
      }
      // Invalidate cache
      _ticketCache.remove(id);
      _lastListTime = DateTime.now().subtract(const Duration(hours: 1));
    } catch (_) {
      rethrow;
    }
  }

  // LISTER LES TECHNICIENS (POUR ASSIGNATION)
  static List<Map<String, dynamic>>? _cachedTechniciens;
  static DateTime _lastTechniciensTime = DateTime.now().subtract(const Duration(hours: 1));

  Future<List<Map<String, dynamic>>> listerTechniciens(
      {bool forceRefresh = false}) async {
    // Retourner cache si valide
    if (!forceRefresh &&
        DateTime.now().difference(_lastTechniciensTime) < _cacheDuration &&
        _cachedTechniciens != null) {
      return _cachedTechniciens!;
    }

    try {
      final technicienUrl =
          _baseUrl.replaceAll('/tickets', '') + ApiConfig.techniciensList;
      final response = await _getWithTimeout(
        Uri.parse(technicienUrl),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _cachedTechniciens =
            List<Map<String, dynamic>>.from(data['results'] ?? data);
        _lastTechniciensTime = DateTime.now();
        return _cachedTechniciens!;
      }
      throw Exception(
          'Erreur lors du chargement des techniciens: ${response.body}');
    } catch (_) {
      // Retourner cache même expiré en cas d'erreur
      if (_cachedTechniciens != null) return _cachedTechniciens!;
      rethrow;
    }
  }
}

// CLASSE POUR CACHER LES TICKETS
class CachedTicket {
  final Ticket ticket;
  final DateTime fetchTime;

  CachedTicket(this.ticket, this.fetchTime);
}