import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:chatapp/data/models/login_request.dart';
import 'package:chatapp/data/models/login_response.dart';

class AuthService {
  String get _baseUrl => dotenv.env['BASE_URL'] ?? '';

  Future<LoginResponse> login({
    required String username,
    required String password,
    LoginRequest? request,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    final credentials = base64Encode(utf8.encode('$username:$password'));
    final body = request ?? LoginRequest();
    
    debugPrint('════════════════════════════════════════');
    debugPrint('🔐 AuthService - Login Request');
    debugPrint('📍 URL: $url');
    debugPrint('👤 Username: $username');
    debugPrint('📦 Body: ${jsonEncode(body.toJson())}');
    debugPrint('🔑 Auth: Basic $credentials');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Basic $credentials',
        },
        body: jsonEncode(body.toJson()),
      );

      debugPrint('📡 Response Status: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.body}');
      debugPrint('════════════════════════════════════════');

      final json = jsonDecode(response.body);
      return LoginResponse.fromJson(json);
    } catch (e) {
      debugPrint('❌ AuthService Error: $e');
      debugPrint('════════════════════════════════════════');
      rethrow;
    }
  }
}
