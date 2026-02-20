import 'package:flutter/foundation.dart';
import 'package:chatapp/core/utils/user_storage.dart';
import 'package:chatapp/data/models/login_request.dart';
import 'package:chatapp/data/models/login_response.dart';
import 'package:chatapp/data/services/api/auth_service.dart';

class AuthRepository {
  final AuthService _authService;
  final UserStorage _userStorage;

  AuthRepository(this._authService, this._userStorage);

  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    debugPrint('════════════════════════════════════════');
    debugPrint('🏛️ AuthRepository - Login');
    debugPrint('👤 Username: $username');

    final response = await _authService.login(
      username: username,
      password: password,
      request: LoginRequest(),
    );

    if (response.isSuccess && response.data != null) {
      debugPrint('✅ Login Success');
      debugPrint('🎫 Token Type: ${response.data!.type}');
      debugPrint('⏱️ Expires In: ${response.data!.expiresIn} minutes');
      
      await _userStorage.saveToken(
        response.data!.authToken,
        response.data!.type,
      );
      debugPrint('💾 Token saved to storage');
    } else {
      debugPrint('❌ Login Failed: ${response.message}');
    }
    debugPrint('════════════════════════════════════════');

    return response;
  }

  Future<bool> isLoggedIn() async {
    return await _userStorage.hasToken();
  }

  Future<void> logout() async {
    debugPrint('🔓 Logout - Clearing token');
    await _userStorage.clearToken();
  }

  Future<String?> getToken() async {
    return await _userStorage.getToken();
  }
}
