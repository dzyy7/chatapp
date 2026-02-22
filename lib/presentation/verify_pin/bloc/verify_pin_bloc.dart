import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatapp/data/repositories/chat_room_repository.dart';
import 'package:chatapp/presentation/verify_pin/bloc/verify_pin_event.dart';
import 'package:chatapp/presentation/verify_pin/bloc/verify_pin_state.dart';

class VerifyPinBloc extends Bloc<VerifyPinEvent, VerifyPinState> {
  final ChatRoomRepository _chatRoomRepository;

  VerifyPinBloc(this._chatRoomRepository) : super(VerifyPinInitial()) {
    on<VerifyPinSubmitEvent>(_onSubmit);
  }

  Future<void> _onSubmit(
    VerifyPinSubmitEvent event,
    Emitter<VerifyPinState> emit,
  ) async {
    debugPrint('════════════════════════════════════════');
    debugPrint('🔐 VerifyPinBloc - Submit');
    debugPrint('📍 GroupId: ${event.groupId}');
    debugPrint('🔑 PIN: ${event.pin}');

    emit(VerifyPinLoading());
    debugPrint('⏳ State: VerifyPinLoading');

    try {
      final response = await _chatRoomRepository.verifyPin(
        groupId: event.groupId,
        pin: event.pin,
      );

      if (response.isSuccess) {
        debugPrint('✅ VerifyPinBloc - PIN Verified');
        emit(VerifyPinSuccess(groupId: event.groupId, pin: event.pin));
      } else {
        debugPrint('❌ VerifyPinBloc - PIN Invalid: ${response.message}');
        emit(VerifyPinError(message: response.message));
      }
    } catch (e) {
      debugPrint('💥 VerifyPinBloc - Exception: $e');
      emit(VerifyPinError(message: e.toString()));
    }
    debugPrint('════════════════════════════════════════');
  }
}
