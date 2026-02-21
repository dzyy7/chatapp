import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatapp/data/models/chat_message.dart';
import 'package:chatapp/data/repositories/chat_room_repository.dart';
import 'package:chatapp/presentation/chat/bloc/chat_event.dart';
import 'package:chatapp/presentation/chat/bloc/chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRoomRepository _chatRoomRepository;
  StreamSubscription<ChatMessage>? _messageSubscription;
  List<ChatMessage> _messages = [];
  int _currentPage = 1;
  bool _hasMoreHistory = true;
  String? _groupId;

  ChatBloc(this._chatRoomRepository) : super(ChatInitial()) {
    on<ChatConnectEvent>(_onConnect);
    on<ChatLoadHistoryEvent>(_onLoadHistory);
    on<ChatSendMessageEvent>(_onSendMessage);
    on<ChatMessageReceivedEvent>(_onMessageReceived);
    on<ChatDisconnectEvent>(_onDisconnect);
  }

  Future<void> _onConnect(
    ChatConnectEvent event,
    Emitter<ChatState> emit,
  ) async {
    debugPrint('🎯 ChatBloc - Connect to group: ${event.groupId}');
    emit(ChatConnecting(group: event.group));

    _messages = [];
    _currentPage = 1;
    _hasMoreHistory = true;
    _groupId = event.groupId;

    try {
      final historyData = await _chatRoomRepository.getChatHistory(
        event.groupId,
        page: _currentPage,
        size: 20, 
      );

      _messages = historyData.items;
      _hasMoreHistory = _messages.length < historyData.total;

      await _chatRoomRepository.connect(event.groupId);

      _messageSubscription = _chatRoomRepository.messageStream.listen((
        message,
      ) {
        add(ChatMessageReceivedEvent(message: message));
      });

      emit(
        ChatConnected(
          group: event.group,
          messages: _messages,
          hasMoreHistory: _hasMoreHistory,
        ),
      );
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onLoadHistory(
    ChatLoadHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatConnected) return;
    final currentState = state as ChatConnected;
    if (currentState.isLoadingHistory || !_hasMoreHistory) return;

    emit(currentState.copyWith(isLoadingHistory: true));

    try {
      _currentPage++;

      final historyData = await _chatRoomRepository.getChatHistory(
        _groupId!,
        page: _currentPage,
        size: 20,
      );

      final olderMessages = historyData.items;

      _messages = [..._messages, ...olderMessages];
      _hasMoreHistory = historyData.hasMore;

      emit(
        ChatConnected(
          group: currentState.group,
          messages: _messages,
          hasMoreHistory: _hasMoreHistory,
          isLoadingHistory: false,
        ),
      );
    } catch (e) {
      _currentPage--;
      emit(currentState.copyWith(isLoadingHistory: false));
    }
  }

  void _onSendMessage(ChatSendMessageEvent event, Emitter<ChatState> emit) {
    if (state is ChatConnected) {
      debugPrint('📤 ChatBloc - Sending message: ${event.text}');
      _chatRoomRepository.sendMessage(event.text);
    }
  }

  void _onMessageReceived(
    ChatMessageReceivedEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatConnected) {
      final currentState = state as ChatConnected;
      debugPrint('📥 ChatBloc - Message received: ${event.message.text}');

      _messages = [event.message, ..._messages];

      emit(currentState.copyWith(messages: _messages));
    }
  }

  void _onDisconnect(ChatDisconnectEvent event, Emitter<ChatState> emit) {
    debugPrint('🔌 ChatBloc - Disconnecting');
    _messageSubscription?.cancel();
    _messageSubscription = null;
    _chatRoomRepository.disconnect();
    _messages = [];
    _currentPage = 1;
    _hasMoreHistory = true;
    _groupId = null;
    emit(ChatInitial());
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _chatRoomRepository.disconnect();
    return super.close();
  }
}
