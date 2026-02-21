import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:chatapp/core/utils/user_storage.dart';
import 'package:chatapp/data/models/chat_group.dart';
import 'package:chatapp/data/models/chat_group_request.dart';
import 'package:chatapp/data/models/chat_group_response.dart';
import 'package:chatapp/data/models/chat_groups_response.dart';
import 'package:chatapp/data/models/chat_history_response.dart';

class ChatService {
  final UserStorage _userStorage;

  ChatService(this._userStorage);

  String get _baseUrl => dotenv.env['BASE_URL'] ?? '';

  Future<ChatGroupResponse> createGroup(ChatGroupRequest request) async {
    final url = Uri.parse('$_baseUrl/admin/group/create');
    final authHeader = await _userStorage.getAuthorizationHeader();

    debugPrint('════════════════════════════════════════');
    debugPrint('💬 ChatService - Create Group Request');
    debugPrint('📍 URL: $url');
    debugPrint('📦 Body: ${jsonEncode(request.toJson())}');
    debugPrint('🔑 Auth: $authHeader');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (authHeader != null) 'Authorization': authHeader,
        },
        body: jsonEncode(request.toJson()),
      );

      debugPrint('📡 Response Status: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.body}');
      debugPrint('════════════════════════════════════════');

      final json = jsonDecode(response.body);
      return ChatGroupResponse.fromJson(json);
    } catch (e) {
      debugPrint('❌ ChatService Error: $e');
      debugPrint('════════════════════════════════════════');
      rethrow;
    }
  }

  Future<List<ChatGroup>> getMyGroups() async {
    final url = Uri.parse('$_baseUrl/group/my_groups');
    final authHeader = await _userStorage.getAuthorizationHeader();

    debugPrint('════════════════════════════════════════');
    debugPrint('💬 ChatService - Get My Groups');
    debugPrint('📍 URL: $url');
    debugPrint('🔑 Auth: $authHeader');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (authHeader != null) 'Authorization': authHeader,
        },
      );

      debugPrint('📡 Response Status: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.body}');
      debugPrint('════════════════════════════════════════');

      final json = jsonDecode(response.body);
      final groupsResponse = ChatGroupsResponse.fromJson(json);

      if (groupsResponse.isSuccess) {
        debugPrint('✅ Loaded ${groupsResponse.data.length} groups');
        return groupsResponse.data;
      } else {
        throw Exception(groupsResponse.message);
      }
    } catch (e) {
      debugPrint('❌ ChatService Error: $e');
      debugPrint('════════════════════════════════════════');
      rethrow;
    }
  }

  Future<ChatHistoryResponse> getChatHistory(
    String groupId, {
    int page = 1,
    int size = 10,
  }) async {
    final url = Uri.parse('$_baseUrl/group/chat_history/$groupId?page=$page&size=$size');
    final authHeader = await _userStorage.getAuthorizationHeader();

    debugPrint('════════════════════════════════════════');
    debugPrint('💬 ChatService - Get Chat History');
    debugPrint('📍 URL: $url');
    debugPrint('🔑 Auth: $authHeader');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (authHeader != null) 'Authorization': authHeader,
        },
      );

      debugPrint('📡 Response Status: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.body}');
      debugPrint('════════════════════════════════════════');

      final json = jsonDecode(response.body);
      return ChatHistoryResponse.fromJson(json);
    } catch (e) {
      debugPrint('❌ ChatService Error: $e');
      debugPrint('════════════════════════════════════════');
      rethrow;
    }
  }
}
