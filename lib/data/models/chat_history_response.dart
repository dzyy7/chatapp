import 'package:chatapp/data/models/chat_message.dart';

class ChatHistoryResponse {
  final int statusCode;
  final String type;
  final String message;
  final ChatHistoryData data;

  ChatHistoryResponse({
    required this.statusCode,
    required this.type,
    required this.message,
    required this.data,
  });

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ChatHistoryResponse(
      statusCode: json['status_code'] ?? 0,
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      data: ChatHistoryData.fromJson(json['data'] ?? {}),
    );
  }

  bool get isSuccess => statusCode == 200;
}

class ChatHistoryData {
  final int size;
  final int page;
  final String sortby;
  final String order;
  final int total;
  final List<ChatMessage> items;

  ChatHistoryData({
    required this.size,
    required this.page,
    required this.sortby,
    required this.order,
    required this.total,
    required this.items,
  });

  factory ChatHistoryData.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];

    return ChatHistoryData(
      size: json['size'] ?? 10,
      page: json['page'] ?? 1,
      sortby: json['sortby'] ?? 'createdTime',
      order: json['order'] ?? 'desc',
      total: json['total'] ?? 0,
      items: itemsList
          .map((item) => ChatMessage.fromHistoryJson(item))
          .toList(),
    );
  }

  bool get hasMore => (page * size) < total;
}
