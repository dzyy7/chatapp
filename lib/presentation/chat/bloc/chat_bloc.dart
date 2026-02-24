import 'dart:async';
import 'package:chatapp/data/models/chat_message_reaction.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatapp/data/models/chat_message.dart';
import 'package:chatapp/data/repositories/chat_room_repository.dart';
import 'package:chatapp/presentation/chat/bloc/chat_event.dart';
import 'package:chatapp/presentation/chat/bloc/chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRoomRepository _chatRoomRepository;
  StreamSubscription<ChatMessage>? _messageSubscription;
  StreamSubscription? _reactionSubscription;
  List<ChatMessage> _messages = [];
  int _currentPage = 1;
  bool _hasMoreHistory = true;
  String? _groupId;

  ChatBloc(this._chatRoomRepository) : super(ChatInitial()) {
    on<ChatConnectEvent>(_onConnect);
    on<ChatLoadHistoryEvent>(_onLoadHistory);
    on<ChatSendMessageEvent>(_onSendMessage);
    on<ChatMessageReceivedEvent>(_onMessageReceived);
    on<ChatReactMessageEvent>(_onReactMessage);
    on<ChatUnreactMessageEvent>(_onUnreactMessage);
    on<ChatReactionReceivedEvent>(_onReactionReceived);
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

      await _chatRoomRepository.connect(event.groupId, pin: event.pin);

      _messageSubscription = _chatRoomRepository.messageStream.listen((message) {
        add(ChatMessageReceivedEvent(message: message));
      });

      _reactionSubscription = _chatRoomRepository.reactionStream.listen((reactionEvent) {
        add(ChatReactionReceivedEvent(reactionEvent: reactionEvent));
      });

      emit(ChatConnected(
        group: event.group,
        messages: List.of(_messages),
        hasMoreHistory: _hasMoreHistory,
        currentUserId: _chatRoomRepository.currentUserId,
      ));
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

      _messages = [..._messages, ...historyData.items];
      _hasMoreHistory = historyData.hasMore;

      emit(ChatConnected(
        group: currentState.group,
        messages: List.of(_messages),
        hasMoreHistory: _hasMoreHistory,
        isLoadingHistory: false,
        currentUserId: currentState.currentUserId,
      ));
    } catch (e) {
      _currentPage--;
      emit(currentState.copyWith(isLoadingHistory: false));
    }
  }

  void _onSendMessage(ChatSendMessageEvent event, Emitter<ChatState> emit) {
    if (state is! ChatConnected) return;
    final currentState = state as ChatConnected;

    debugPrint('📤 ChatBloc - Sending message: ${event.text}');
    _chatRoomRepository.sendMessage(event.text);

    final optimisticMessage = ChatMessage(
      messageId: 'optimistic_${DateTime.now().millisecondsSinceEpoch}',
      userId: currentState.currentUserId,
      userName: null,
      text: event.text,
      createdTime: DateTime.now().toUtc(),
      isMine: true,
      reactions: const [],
    );

    _messages = [optimisticMessage, ..._messages];
    emit(currentState.copyWith(messages: List.of(_messages), bumpVersion: true));
  }

  void _onMessageReceived(
    ChatMessageReceivedEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatConnected) return;
    final currentState = state as ChatConnected;

    final correctedMessage = event.message.copyWith(
      isMine: currentState.currentUserId != null &&
          event.message.userId == currentState.currentUserId,
    );

    debugPrint('📥 ChatBloc - Message received: ${correctedMessage.text} | isMine: ${correctedMessage.isMine}');

    if (correctedMessage.isMine) {
      final optimisticIndex = _messages.indexWhere(
        (m) =>
            m.messageId != null &&
            m.messageId!.startsWith('optimistic_') &&
            m.text == correctedMessage.text,
      );
      if (optimisticIndex != -1) {
        _messages = List.of(_messages);
        _messages[optimisticIndex] = correctedMessage;
        emit(currentState.copyWith(messages: List.of(_messages), bumpVersion: true));
        return;
      }
    }

    // Pesan dari user lain — prepend seperti biasa
    _messages = [correctedMessage, ..._messages];
    emit(currentState.copyWith(messages: List.of(_messages), bumpVersion: true));
  }

  void _onReactMessage(
    ChatReactMessageEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatConnected) return;
    final currentState = state as ChatConnected;

    debugPrint('👍 ChatBloc - React: ${event.messageId} with ${event.emoji}');
    _chatRoomRepository.reactMessage(event.messageId, event.emoji);

    final userId = currentState.currentUserId ?? '';
    _messages = _messages.map((msg) {
      if (msg.messageId != event.messageId) return msg;

      final updatedReactions = msg.reactions
          .where((r) => r.userId != userId)
          .toList()
        ..add(MessageReaction(
          emoji: event.emoji,
          userId: userId,
          createdTime: DateTime.now().toUtc(),
        ));

      return msg.copyWith(reactions: updatedReactions);
    }).toList();

    emit(currentState.copyWith(messages: List.of(_messages), bumpVersion: true));
  }

  void _onUnreactMessage(
    ChatUnreactMessageEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatConnected) return;
    final currentState = state as ChatConnected;

    debugPrint('👎 ChatBloc - Unreact: ${event.messageId} emoji ${event.emoji}');
    _chatRoomRepository.unreactMessage(event.messageId, event.emoji);

    // OPTIMISTIC UPDATE: langsung hapus reaction dari UI
    final userId = currentState.currentUserId ?? '';
    _messages = _messages.map((msg) {
      if (msg.messageId != event.messageId) return msg;

      final updatedReactions = msg.reactions
          .where((r) => !(r.userId == userId && r.emoji == event.emoji))
          .toList();

      return msg.copyWith(reactions: updatedReactions);
    }).toList();

    emit(currentState.copyWith(messages: List.of(_messages), bumpVersion: true));
  }

  void _onReactionReceived(
    ChatReactionReceivedEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatConnected) return;
    final currentState = state as ChatConnected;
    final re = event.reactionEvent;

    debugPrint('💬 ChatBloc - Reaction broadcast received: ${re.emoji} (${re.action}) on ${re.messageId}');

    // Server sudah kasih reactions terbaru (dari semua user) — pakai data server
    // sebagai source of truth, replace optimistic kita dengan data real
    _messages = _messages.map((msg) {
      if (msg.messageId != re.messageId) return msg;
      return msg.copyWith(reactions: List.of(re.reactions));
    }).toList();

    emit(currentState.copyWith(messages: List.of(_messages), bumpVersion: true));
  }

  void _onDisconnect(ChatDisconnectEvent event, Emitter<ChatState> emit) {
    debugPrint('🔌 ChatBloc - Disconnecting');
    _messageSubscription?.cancel();
    _messageSubscription = null;
    _reactionSubscription?.cancel();
    _reactionSubscription = null;
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
    _reactionSubscription?.cancel();
    _chatRoomRepository.disconnect();
    return super.close();
  }
}