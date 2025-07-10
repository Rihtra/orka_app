import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _authTokenKey = 'auth_token';

  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_authTokenKey, token);
      print('Token saved: $token'); // Debug
    } catch (e) {
      print('Error saving token: $e');
      rethrow;
    }
  }

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_authTokenKey);
      print('Retrieved token: $token'); // Debug
      return token;
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  static Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_authTokenKey);
      print('Token cleared'); // Debug
    } catch (e) {
      print('Error clearing token: $e');
      rethrow;
    }
  }
}