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

  const ChatConnected({
    required this.group,
    required this.messages,
    this.hasMoreHistory = false,
    this.isLoadingHistory = false,
  });

  ChatConnected copyWith({
    ChatGroup? group,
    List<ChatMessage>? messages,
    bool? hasMoreHistory,
    bool? isLoadingHistory,
  }) {
    return ChatConnected(
      group: group ?? this.group,
      messages: messages ?? this.messages,
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
    );
  }

  @override
  List<Object?> get props => [group, messages, hasMoreHistory, isLoadingHistory];
}

class ChatError extends ChatState {
  final String message;

  const ChatError({required this.message});

  @override
  List<Object?> get props => [message];
}
