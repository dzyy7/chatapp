import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserStorage {
  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserData = 'user_data';
  static const String _keyIsFirstTime = 'is_first_time';
  static const String _keyIsLoggedIn = 'is_logged_in';

  final SharedPreferences _prefs;

  UserStorage(this._prefs);

  Future<void> saveToken(String token) async {
    await _prefs.setString(_keyToken, token);
  }

  String? getToken() {
    return _prefs.getString(_keyToken);
  }

  Future<void> saveUserId(String userId) async {
    await _prefs.setString(_keyUserId, userId);
  }

  String? getUserId() {
    return _prefs.getString(_keyUserId);
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs.setString(_keyUserData, jsonEncode(userData));
  }

  Map<String, dynamic>? getUserData() {
    final data = _prefs.getString(_keyUserData);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  Future<void> setFirstTime(bool isFirstTime) async {
    await _prefs.setBool(_keyIsFirstTime, isFirstTime);
  }

  bool isFirstTime() {
    return _prefs.getBool(_keyIsFirstTime) ?? true;
  }

  Future<void> setLoggedIn(bool isLoggedIn) async {
    await _prefs.setBool(_keyIsLoggedIn, isLoggedIn);
  }

  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }

  Future<void> clearSession() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserData);
    await _prefs.setBool(_keyIsLoggedIn, false);
  }
}
