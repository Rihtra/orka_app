class ApiConfig {
  // Ganti dengan URL API Laravel Anda
  static const String baseUrl = 'http://192.168.228.253:8000/api/organisasi/'; // Untuk emulator Android
  // static const String baseUrl = 'http://10.0.2.2:8000/api'; // Alternatif untuk emulator
  // static const String baseUrl = 'http://192.168.1.100:8000/api'; // Untuk device fisik
  // static const String baseUrl = 'https://your-domain.com/api'; // Untuk production
  
  static const int timeoutDuration = 30; // seconds
  
  // Headers default
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Headers dengan authentication (jika diperlukan)
  static Map<String, String> getAuthHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
  
  // Endpoints
  static const String organisasiEndpoint = '/organisasi';
  static String organisasiDetailEndpoint(int id) => '/organisasi/$id';
  static String organisasiDivisiEndpoint(int id) => '/organisasi/$id/divisi';
}