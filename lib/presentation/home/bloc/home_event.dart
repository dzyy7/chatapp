import 'package:equatable/equatable.dart';
import 'package:chatapp/data/models/chat_group.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeLoadGroupsEvent extends HomeEvent {}

class HomeCreateGroupEvent extends HomeEvent {
  final String name;
  final String description;
  final int pin;

  const HomeCreateGroupEvent({
    required this.name,
    required this.description,
    required this.pin,
  });

  @override
  List<Object?> get props => [name, description, pin];
}

class HomeDeleteGroupEvent extends HomeEvent {
  final ChatGroup group;

  const HomeDeleteGroupEvent({required this.group});

  @override
  List<Object?> get props => [group];
}
