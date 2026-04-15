import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

// Configuration centralisée pour les appels API
class ApiConfig {
  // Déterminer l'adresse IP du backend selon l'environnement
  static String get baseUrl {
    // Sur émulateur Android : 10.0.2.2 remplace localhost
    // Sur device physique Android ou iOS : utiliser l'IP du serveur local
    // Sur desktop : utiliser localhost
    // Sur web : utiliser localhost
    
    const String _backendHost = String.fromEnvironment(
      'BACKEND_HOST',
      defaultValue: '',
    );
    const String _backendPort = String.fromEnvironment(
      'BACKEND_PORT',
      defaultValue: '8000',
    );

    final host = _backendHost.isNotEmpty ? _backendHost : _defaultHostForPlatform();
    return 'http://$host:$_backendPort/api';
  }

  static String _defaultHostForPlatform() {
    if (kIsWeb) return 'localhost';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return '10.0.2.2';
      case TargetPlatform.iOS:
        return '127.0.0.1';
      default:
        return '127.0.0.1';
    }
  }

  // TIMEOUTS (en secondes)
  static const int connectTimeout = 15;
  static const int receiveTimeout = 15;
  static const int sendTimeout = 15;

  // ENDPOINTS
  static const String authLogin = '/auth/login/';
  static const String authRegister = '/auth/register/';
  static const String authRefresh = '/auth/refresh/';
  static const String authProfile = '/auth/profile/';
  
  static const String ticketsList = '/tickets/';
  static const String ticketsDetail = '/tickets/{id}/';
  static const String ticketsCreate = '/tickets/';
  static const String ticketsChangeStatus = '/tickets/{id}/changer_statut/';
  static const String ticketsComment = '/tickets/{id}/commenter/';
  static const String ticketsAssign = '/tickets/{id}/assigner/';
  
  static const String techniciensList = '/techniciens/';
  static const String statisticsUrl = '/statistics/';
}
