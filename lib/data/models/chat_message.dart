import 'package:chatapp/data/models/chat_message_reaction.dart';

class ChatMessage {
  final String? messageId;
  final String? groupId;
  final String? userId;
  final String? userName;
  final String text;
  final DateTime? createdTime;
  final bool isMine;
  final List<MessageReaction> reactions;
  final bool isEdited;
  final bool isDeleted;
  final String? replyToId;

  ChatMessage({
    this.messageId,
    this.groupId,
    this.userId,
    this.userName,
    required this.text,
    this.createdTime,
    this.isMine = false,
    this.reactions = const [],
    this.isEdited = false,
    this.isDeleted = false,
    this.replyToId,
  });

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final messageId = json['messageId']?.toString() ?? json['_id']?.toString();
    final reactionsList = (json['reactions'] as List<dynamic>? ?? [])
        .map((r) => MessageReaction.fromJson(r as Map<String, dynamic>))
        .toList();

    return ChatMessage(
      messageId: messageId,
      groupId: json['groupId']?.toString(),
      userId: json['userId']?.toString(),
      userName: json['userName']?.toString(),
      text: json['text'] ?? '',
      createdTime: json['createdTime'] != null
          ? DateTime.tryParse(json['createdTime'])
          : null,
      isMine:
          currentUserId != null &&
          json['userId']?.toString() == currentUserId,
      reactions: reactionsList,
      isEdited: json['isEdited'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      replyToId: json['replyToId']?.toString(),
    );
  }

  factory ChatMessage.fromHistoryJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final reactionsList = (json['reactions'] as List<dynamic>? ?? [])
        .map((r) => MessageReaction.fromJson(r as Map<String, dynamic>))
        .toList();

    return ChatMessage(
      messageId: json['_id']?.toString(),
      groupId: json['groupId']?.toString(),
      userId: json['userId']?.toString(),
      userName: null,
      text: json['text'] ?? '',
      createdTime: json['createdTime'] != null
          ? DateTime.tryParse(json['createdTime'])
          : null,
      isMine:
          currentUserId != null &&
          json['userId']?.toString() == currentUserId,
      reactions: reactionsList,
      isEdited: json['isEdited'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      replyToId: json['replyToId']?.toString(),
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
    List<MessageReaction>? reactions,
    bool? isEdited,
    bool? isDeleted,
    String? replyToId,
  }) {
    return ChatMessage(
      messageId: messageId ?? this.messageId,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      text: text ?? this.text,
      createdTime: createdTime ?? this.createdTime,
      isMine: isMine ?? this.isMine,
      reactions: reactions ?? this.reactions,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      replyToId: replyToId ?? this.replyToId,
    );
  }

  /// Group reactions by emoji with count
  Map<String, List<MessageReaction>> get groupedReactions {
    final Map<String, List<MessageReaction>> grouped = {};
    for (final reaction in reactions) {
      grouped.putIfAbsent(reaction.emoji, () => []).add(reaction);
    }
    return grouped;
  }

  /// Check if current user has reacted with a specific emoji
  bool hasUserReacted(String userId, String emoji) {
    return reactions.any((r) => r.userId == userId && r.emoji == emoji);
  }
}