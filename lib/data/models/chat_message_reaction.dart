class MessageReaction {
  final String emoji;
  final String userId;
  final DateTime? createdTime;

  MessageReaction({
    required this.emoji,
    required this.userId,
    this.createdTime,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      emoji: json['emoji'] ?? '',
      userId: json['userId']?.toString() ?? '',
      createdTime: json['createdTime'] != null
          ? DateTime.tryParse(json['createdTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'userId': userId,
      'createdTime': createdTime?.toIso8601String(),
    };
  }
}