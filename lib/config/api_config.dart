class ApiConfig {
  // IMPORTANT: Change cette URL selon ton environnement
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Pour Android Emulator, utilise: http://10.0.2.2:3000/api
  // Pour appareil réel, utilise ton IP locale: http://192.168.1.X:3000/api
  
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String registerEndpoint = '$baseUrl/auth/register';
  static const String createDossierEndpoint = '$baseUrl/dossiers/create';
  
  static const Duration timeout = Duration(seconds: 30);
}
