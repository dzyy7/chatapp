import 'package:equatable/equatable.dart';
import 'package:chatapp/data/models/chat_message.dart';
import 'package:chatapp/data/models/chat_group.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatConnectEvent extends ChatEvent {
  final String groupId;
  final ChatGroup group;

  const ChatConnectEvent({
    required this.groupId,
    required this.group,
  });

  @override
  List<Object?> get props => [groupId, group];
}

class ChatLoadHistoryEvent extends ChatEvent {
  final int page;

  const ChatLoadHistoryEvent({this.page = 1});

  @override
  List<Object?> get props => [page];
}

class ChatSendMessageEvent extends ChatEvent {
  final String text;

  const ChatSendMessageEvent({required this.text});

  @override
  List<Object?> get props => [text];
}

class ChatMessageReceivedEvent extends ChatEvent {
  final ChatMessage message;

  const ChatMessageReceivedEvent({required this.message});

  @override
  List<Object?> get props => [message];
}

class ChatDisconnectEvent extends ChatEvent {}
