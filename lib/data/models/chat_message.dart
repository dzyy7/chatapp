class ChatMessage {
  final String? messageId;
  final String? groupId;
  final String? userId;
  final String? userName;
  final String text;
  final DateTime? createdTime;
  final bool isMine;

  ChatMessage({
    this.messageId,
    this.groupId,
    this.userId,
    this.userName,
    required this.text,
    this.createdTime,
    this.isMine = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final messageId = json['messageId']?.toString() ?? json['_id']?.toString();
    
    return ChatMessage(
      messageId: messageId,
      groupId: json['groupId']?.toString(),
      userId: json['userId']?.toString(),
      userName: json['userName']?.toString(),
      text: json['text'] ?? '',
      createdTime: json['createdTime'] != null
          ? DateTime.tryParse(json['createdTime'])
          : null,
      isMine: currentUserId != null && json['userId']?.toString() == currentUserId,
    );
  }

  factory ChatMessage.fromHistoryJson(Map<String, dynamic> json, {String? currentUserId}) {
    return ChatMessage(
      messageId: json['_id']?.toString(),
      groupId: json['groupId']?.toString(),
      userId: json['userId']?.toString(),
      userName: null,
      text: json['text'] ?? '',
      createdTime: json['createdTime'] != null
          ? DateTime.tryParse(json['createdTime'])
          : null,
      isMine: currentUserId != null && json['userId']?.toString() == currentUserId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': 'chat',
      'text': text,
    };
  }

  ChatMessage copyWith({
    String? messageId,
    String? groupId,
    String? userId,
    String? userName,
    String? text,
    DateTime? createdTime,
    bool? isMine,
  }) {
    return ChatMessage(
      messageId: messageId ?? this.messageId,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      text: text ?? this.text,
      createdTime: createdTime ?? this.createdTime,
      isMine: isMine ?? this.isMine,
    );
  }
}
