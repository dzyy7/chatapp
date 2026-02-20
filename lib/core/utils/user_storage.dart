import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  static const String _tokenKey = 'auth_token';
  static const String _tokenTypeKey = 'token_type';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> saveToken(String token, String type) async {
    final prefs = await _prefs;
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_tokenTypeKey, type);
  }

  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_tokenKey);
  }

  Future<String?> getTokenType() async {
    final prefs = await _prefs;
    return prefs.getString(_tokenTypeKey);
  }

  Future<String?> getAuthorizationHeader() async {
    final token = await getToken();
    final type = await getTokenType();
    if (token != null && type != null) {
      return '$type $token';
    }
    return null;
  }

  Future<void> clearToken() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
    await prefs.remove(_tokenTypeKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
