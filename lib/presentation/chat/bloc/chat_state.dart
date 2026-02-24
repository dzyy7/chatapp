import 'package:equatable/equatable.dart';
import 'package:chatapp/data/models/chat_message.dart';
import 'package:chatapp/data/models/chat_group.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatConnecting extends ChatState {
  final ChatGroup group;

  const ChatConnecting({required this.group});

  @override
  List<Object?> get props => [group];
}

class ChatConnected extends ChatState {
  final ChatGroup group;
  final List<ChatMessage> messages;
  final bool hasMoreHistory;
  final bool isLoadingHistory;
  final String? currentUserId;
  
  final int _version;

  const ChatConnected({
    required this.group,
    required this.messages,
    this.hasMoreHistory = false,
    this.isLoadingHistory = false,
    this.currentUserId,
    int version = 0,
  }) : _version = version;

  ChatConnected copyWith({
    ChatGroup? group,
    List<ChatMessage>? messages,
    bool? hasMoreHistory,
    bool? isLoadingHistory,
    String? currentUserId,
    bool bumpVersion = false,
  }) {
    return ChatConnected(
      group: group ?? this.group,
      messages: messages ?? this.messages,
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      currentUserId: currentUserId ?? this.currentUserId,
      version: bumpVersion ? _version + 1 : _version,
    );
  }

  @override
  List<Object?> get props => [
    group,
    messages,
    hasMoreHistory,
    isLoadingHistory,
    currentUserId,
    _version,
  ];
}

class ChatError extends ChatState {
  final String message;

  const ChatError({required this.message});

  @override
  List<Object?> get props => [message];
}
