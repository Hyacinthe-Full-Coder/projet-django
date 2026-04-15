// Configuration centralisée pour les appels API
class ApiConfig {
  // Déterminer l'adresse IP du backend selon l'environnement
  static String get baseUrl {
    // Sur émulateur Android : 10.0.2.2 remplace localhost
    // Sur device physique : utiliser l'IP du serveur (À CONFIGURER)
    // Sur web : utiliser localhost
    
    const String _backendHost = String.fromEnvironment(
      'BACKEND_HOST',
      defaultValue: '10.0.2.2', // Android émulateur
    );
    const String _backendPort = String.fromEnvironment(
      'BACKEND_PORT',
      defaultValue: '8000',
    );
    
    return 'http://$_backendHost:$_backendPort/api';
  }

  // TIMEOUTS (en secondes)
  static const int connectTimeout = 15;
  static const int receiveTimeout = 15;
  static const int sendTimeout = 15;

  // ENDPOINTS
  static const String authLogin = '/auth/login/';
  static const String authRegister = '/auth/register/';
  static const String authRefresh = '/auth/refresh/';
  static const String authProfile = '/auth/me/';
  
  static const String ticketsList = '/tickets/';
  static const String ticketsDetail = '/tickets/{id}/';
  static const String ticketsCreate = '/tickets/';
  static const String ticketsChangeStatus = '/tickets/{id}/changer_statut/';
  static const String ticketsComment = '/tickets/{id}/commenter/';
  static const String ticketsAssign = '/tickets/{id}/assigner/';
  
  static const String techniciensList = '/techniciens/';
  static const String statisticsUrl = '/statistics/';
}
