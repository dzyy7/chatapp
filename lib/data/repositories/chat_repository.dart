import 'package:flutter/foundation.dart';
import 'package:chatapp/data/models/chat_group.dart';
import 'package:chatapp/data/models/chat_group_request.dart';
import 'package:chatapp/data/services/api/chat_service.dart';

class ChatRepository {
  final ChatService _chatService;

  ChatRepository(this._chatService);

  Future<List<ChatGroup>> getMyGroups() async {
    debugPrint('════════════════════════════════════════');
    debugPrint('🏛️ ChatRepository - Get My Groups');

    try {
      final groups = await _chatService.getMyGroups();
      debugPrint('✅ Fetched ${groups.length} groups');
      debugPrint('════════════════════════════════════════');
      return groups;
    } catch (e) {
      debugPrint('❌ Get Groups Failed: $e');
      debugPrint('════════════════════════════════════════');
      rethrow;
    }
  }

  Future<ChatGroup> createGroup({
    required String name,
    required String description,
    required int pin,
  }) async {
    debugPrint('════════════════════════════════════════');
    debugPrint('🏛️ ChatRepository - Create Group');
    debugPrint('📝 Name: $name');
    debugPrint('📝 Description: $description');

    final request = ChatGroupRequest(
      name: name,
      description: description,
      pin: pin,
    );

    final response = await _chatService.createGroup(request);

    if (response.isSuccess && response.data != null) {
      debugPrint('✅ Group Created Successfully');
      debugPrint('════════════════════════════════════════');

      return ChatGroup(
        id: response.data!.id,
        name: response.data!.name ?? name,
        description: response.data!.description ?? description,
        pin: response.data!.pin ?? pin,
      );
    } else {
      debugPrint('❌ Group Creation Failed: ${response.message}');
      debugPrint('════════════════════════════════════════');
      throw Exception(response.message);
    }
  }
}
