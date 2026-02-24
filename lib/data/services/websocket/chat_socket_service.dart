import 'dart:async';
import 'dart:convert';
import 'package:chatapp/data/models/chat_message_reaction.dart' show MessageReaction;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/io.dart';
import 'package:chatapp/core/utils/user_storage.dart';
import 'package:chatapp/data/models/chat_message.dart';

class ReactionEvent {
  final String messageId;
  final String groupId;
  final String userId;
  final String userName;
  final String emoji;
  final String action;
  final List<MessageReaction> reactions;

  ReactionEvent({
    required this.messageId,
    required this.groupId,
    required this.userId,
    required this.userName,
    required this.emoji,
    required this.action,
    required this.reactions,
  });
}

class ChatSocketService {
  final UserStorage _userStorage;
  IOWebSocketChannel? _channel;

  // Always-alive broadcast controllers — never closed, only replaced on fresh connect
  late StreamController<ChatMessage> _messageController;
  late StreamController<ReactionEvent> _reactionController;

  String? _currentUserId;
  bool _isConnected = false;

  ChatSocketService(this._userStorage) {
    _messageController = StreamController<ChatMessage>.broadcast();
    _reactionController = StreamController<ReactionEvent>.broadcast();
  }

  String get _baseUrl {
    final httpUrl = dotenv.env['BASE_URL'] ?? '';
    return httpUrl
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');
  }

  // Streams are stable references — subscribers attach once and stay attached
  Stream<ChatMessage> get messageStream => _messageController.stream;
  Stream<ReactionEvent> get reactionStream => _reactionController.stream;

  bool get isConnected => _isConnected;
  String? get currentUserId => _currentUserId;

  Future<void> connect(String groupId, {String? pin}) async {
    // Clean up any existing connection first
    await _closeChannel();

    final token = await _userStorage.getToken();
    if (token != null) {
      _currentUserId = _extractUserIdFromToken(token);
    }

    String urlStr = '$_baseUrl/chat/ws/group_chat/$groupId?token=$token';
    if (pin != null && pin.isNotEmpty) {
      urlStr += '&pin=$pin';
    }

    final url = Uri.parse(urlStr);

    debugPrint('════════════════════════════════════════');
    debugPrint('🔌 ChatSocketService - Connecting');
    debugPrint('📍 URL: $url');
    debugPrint('🔑 Token: ${token?.substring(0, 20)}...');
    if (pin != null) debugPrint('🔐 PIN: $pin');

    try {
      _channel = IOWebSocketChannel.connect(url);
      await _channel!.ready;
      _isConnected = true;
      debugPrint('✅ WebSocket Connected');
      debugPrint('════════════════════════════════════════');

      _channel!.stream.listen(
        (data) {
          debugPrint('📨 Received: $data');
          _handleMessage(data);
        },
        onError: (error) {
          debugPrint('❌ WebSocket Error: $error');
          _isConnected = false;
        },
        onDone: () {
          debugPrint('🔌 WebSocket Disconnected');
          _isConnected = false;
        },
      );
    } catch (e) {
      debugPrint('❌ WebSocket Connection Failed: $e');
      debugPrint('════════════════════════════════════════');
      rethrow;
    }
  }

  void _handleMessage(dynamic data) {
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      final type = json['type'] as String?;

      switch (type) {
        case 'chat':
        case 'reply':
          final message = ChatMessage.fromJson(json, currentUserId: _currentUserId);
          debugPrint('📩 Message from userId: ${json['userId']} | currentUserId: $_currentUserId | isMine: ${message.isMine}');
          _messageController.add(message);
          break;

        case 'reaction':
          final reactionsList = (json['reactions'] as List<dynamic>? ?? [])
              .map((r) => MessageReaction.fromJson(r as Map<String, dynamic>))
              .toList();

          final event = ReactionEvent(
            messageId: json['messageId']?.toString() ?? '',
            groupId: json['groupId']?.toString() ?? '',
            userId: json['userId']?.toString() ?? '',
            userName: json['userName']?.toString() ?? '',
            emoji: json['emoji']?.toString() ?? '',
            action: json['action']?.toString() ?? 'add',
            reactions: reactionsList,
          );
          debugPrint('⚗️ Reaction event: ${event.emoji} on ${event.messageId}');
          _reactionController.add(event);
          break;

        default:
          debugPrint('⚠️ Unhandled message type: $type');
      }
    } catch (e) {
      debugPrint('❌ Error parsing message: $e');
    }
  }

  void sendMessage(String text) => _send({'type': 'chat', 'text': text});
  void sendReply(String replyToId, String text) =>
      _send({'type': 'reply', 'replyToId': replyToId, 'text': text});
  void sendReact(String messageId, String emoji) =>
      _send({'type': 'react', 'messageId': messageId, 'emoji': emoji});
  void sendUnreact(String messageId, String emoji) =>
      _send({'type': 'unreact', 'messageId': messageId, 'emoji': emoji});
  void sendTyping() => _send({'type': 'typing'});

  void _send(Map<String, dynamic> data) {
    if (_channel == null || !_isConnected) {
      debugPrint('❌ WebSocket not connected');
      return;
    }
    final json = jsonEncode(data);
    debugPrint('📤 Sending: $json');
    _channel!.sink.add(json);
  }

  Future<void> _closeChannel() async {
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _isConnected = false;
  }

  void disconnect() {
    debugPrint('🔌 Disconnecting WebSocket');
    _closeChannel();
    // Do NOT close the stream controllers — they are reused across reconnects.
    // BLoC's stream subscriptions stay alive and will receive events on next connect.
  }

  String? _extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      String payload = parts[1];
      switch (payload.length % 4) {
        case 0:
          break;
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }

      final decoded = utf8.decode(base64Url.decode(payload));
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      return json['sub']?.toString();
    } catch (e) {
      debugPrint('❌ Error extracting user ID from token: $e');
      return null;
    }
  }
}