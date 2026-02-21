class ChatGroupResponse {
  final int statusCode;
  final String type;
  final String message;
  final ChatGroupData? data;

  ChatGroupResponse({
    required this.statusCode,
    required this.type,
    required this.message,
    this.data,
  });

  factory ChatGroupResponse.fromJson(Map<String, dynamic> json) {
    return ChatGroupResponse(
      statusCode: json['status_code'] ?? 0,
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] != null ? ChatGroupData.fromJson(json['data']) : null,
    );
  }

  bool get isSuccess => statusCode == 200 || statusCode == 201;
}

class ChatGroupData {
  final String? id;
  final String? name;
  final String? description;
  final int? pin;

  ChatGroupData({
    this.id,
    this.name,
    this.description,
    this.pin,
  });

  factory ChatGroupData.fromJson(Map<String, dynamic> json) {
    return ChatGroupData(
      id: json['id']?.toString(),
      name: json['name'],
      description: json['description'],
      pin: json['pin'],
    );
  }
}
