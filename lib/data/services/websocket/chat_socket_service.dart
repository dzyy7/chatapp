import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:chatapp/core/utils/user_storage.dart';
import 'package:chatapp/data/models/chat_message.dart';

class ChatSocketService {
  final UserStorage _userStorage;
  WebSocketChannel? _channel;
  StreamController<ChatMessage>? _messageController;
  String? _currentUserId;
  bool _isConnected = false;

  ChatSocketService(this._userStorage);

  String get _baseUrl {
    final httpUrl = dotenv.env['BASE_URL'] ?? '';
    return httpUrl.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');
  }

  Stream<ChatMessage> get messageStream {
    _messageController ??= StreamController<ChatMessage>.broadcast();
    return _messageController!.stream;
  }

  bool get isConnected => _isConnected;

  Future<void> connect(String groupId) async {
    final token = await _userStorage.getToken();

    if (token != null) {
      _currentUserId = _extractUserIdFromToken(token);
    }

    final url = Uri.parse('$_baseUrl/ws/group_chat/$groupId?token=$token');

    debugPrint('════════════════════════════════════════');
    debugPrint('🔌 ChatSocketService - Connecting');
    debugPrint('📍 URL: $url');
    debugPrint('🔑 Token: ${token?.substring(0, 20)}...');

    try {
      _channel = WebSocketChannel.connect(url);

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

      if (type == 'chat') {
        final message = ChatMessage.fromJson(
          json,
          currentUserId: _currentUserId,
        );
        _messageController?.add(message);
      }
    } catch (e) {
      debugPrint('❌ Error parsing message: $e');
    }
  }

  void sendMessage(String text) {
    if (_channel == null || !_isConnected) {
      debugPrint('❌ WebSocket not connected');
      return;
    }

    final message = ChatMessage(text: text);
    final json = jsonEncode(message.toJson());

    debugPrint('📤 Sending: $json');
    _channel!.sink.add(json);
  }

  void disconnect() {
    debugPrint('🔌 Disconnecting WebSocket');
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _messageController?.close();
    _messageController = null;
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
