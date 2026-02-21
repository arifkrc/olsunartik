class AppConstants {
  static const String apiBaseUrl = 'http://localhost:5294'; // Local backend
  static const String authTokenKey = 'auth_token';
}

class ApiConstants {
  static const String baseUrl = AppConstants.apiBaseUrl;
  static const String apiBase = '$baseUrl/api';
  static const String authBase = '$baseUrl/api';  
  static const String lookupBase = '$baseUrl/api/lookup';
}
