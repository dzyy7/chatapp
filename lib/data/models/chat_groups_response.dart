import 'package:chatapp/data/models/chat_group.dart';

class ChatGroupsResponse {
  final int statusCode;
  final String type;
  final String message;
  final List<ChatGroup> data;

  ChatGroupsResponse({
    required this.statusCode,
    required this.type,
    required this.message,
    required this.data,
  });

  factory ChatGroupsResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    
    return ChatGroupsResponse(
      statusCode: json['status_code'] ?? 0,
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      data: dataList.map((item) => ChatGroup.fromJson(item)).toList(),
    );
  }

  bool get isSuccess => statusCode == 200;
}
