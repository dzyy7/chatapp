import 'package:chatapp/data/models/chat_message.dart';
import 'package:chatapp/data/models/chat_history_response.dart';
import 'package:chatapp/data/models/verify_pin_request.dart';
import 'package:chatapp/data/models/verify_pin_response.dart';
import 'package:chatapp/data/services/api/chat_service.dart';
import 'package:chatapp/data/services/websocket/chat_socket_service.dart';

class ChatRoomRepository {
  final ChatSocketService _socketService;
  final ChatService _chatService;

  ChatRoomRepository(this._socketService, this._chatService);

  Stream<ChatMessage> get messageStream => _socketService.messageStream;
  Stream<ReactionEvent> get reactionStream => _socketService.reactionStream;

  bool get isConnected => _socketService.isConnected;
  String? get currentUserId => _socketService.currentUserId;

  Future<ChatHistoryData> getChatHistory(
    String groupId, {
    int page = 1,
    int size = 10,
  }) async {
    final response = await _chatService.getChatHistory(
      groupId,
      page: page,
      size: size,
    );

    if (response.isSuccess) {
      return response.data;
    } else {
      throw Exception(response.message);
    }
  }

  Future<void> connect(String groupId, {String? pin}) async {
    await _socketService.connect(groupId, pin: pin);
  }

  void sendMessage(String text) {
    _socketService.sendMessage(text);
  }

  void sendReply(String replyToId, String text) {
    _socketService.sendReply(replyToId, text);
  }

  void reactMessage(String messageId, String emoji) {
    _socketService.sendReact(messageId, emoji);
  }

  void unreactMessage(String messageId, String emoji) {
    _socketService.sendUnreact(messageId, emoji);
  }

  void disconnect() {
    _socketService.disconnect();
  }

  Future<VerifyPinResponse> verifyPin({
    required String groupId,
    required int pin,
  }) async {
    final request = VerifyPinRequest(groupId: groupId, pin: pin);
    return await _chatService.verifyPin(request);
  }
}
