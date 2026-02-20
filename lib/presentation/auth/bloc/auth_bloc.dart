import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatapp/data/repositories/auth_repository.dart';
import 'package:chatapp/presentation/auth/bloc/auth_event.dart';
import 'package:chatapp/presentation/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthLoginEvent>(_onLogin);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthCheckStatusEvent>(_onCheckStatus);
  }

  Future<void> _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    debugPrint('════════════════════════════════════════');
    debugPrint('🎯 AuthBloc - Login Event Received');
    debugPrint('👤 Username: ${event.username}');
    
    emit(AuthLoading());
    debugPrint('⏳ State: AuthLoading');

    try {
      final response = await _authRepository.login(
        username: event.username,
        password: event.password,
      );

      if (response.isSuccess) {
        debugPrint('✅ AuthBloc - Emitting AuthSuccess');
        debugPrint('💬 Message: ${response.message}');
        emit(AuthSuccess(message: response.message));
      } else {
        debugPrint('❌ AuthBloc - Emitting AuthError');
        debugPrint('💬 Message: ${response.message}');
        emit(AuthError(message: response.message));
      }
    } catch (e) {
      debugPrint('💥 AuthBloc - Exception: $e');
      emit(AuthError(message: e.toString()));
    }
    debugPrint('════════════════════════════════════════');
  }

  Future<void> _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    debugPrint('🎯 AuthBloc - Logout Event');
    await _authRepository.logout();
    emit(AuthUnauthenticated());
    debugPrint('✅ State: AuthUnauthenticated');
  }

  Future<void> _onCheckStatus(AuthCheckStatusEvent event, Emitter<AuthState> emit) async {
    debugPrint('🔍 AuthBloc - Check Status');
    final isLoggedIn = await _authRepository.isLoggedIn();
    if (isLoggedIn) {
      debugPrint('✅ User is authenticated');
      emit(AuthAuthenticated());
    } else {
      debugPrint('❌ User is not authenticated');
      emit(AuthUnauthenticated());
    }
  }
}
