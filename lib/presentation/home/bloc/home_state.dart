import 'package:equatable/equatable.dart';
import 'package:chatapp/data/models/chat_group.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ChatGroup> groups;

  const HomeLoaded({required this.groups});

  @override
  List<Object?> get props => [groups];
}

class HomeGroupCreating extends HomeState {
  final List<ChatGroup> groups;

  const HomeGroupCreating({required this.groups});

  @override
  List<Object?> get props => [groups];
}

class HomeGroupCreated extends HomeState {
  final ChatGroup group;
  final List<ChatGroup> groups;

  const HomeGroupCreated({
    required this.group,
    required this.groups,
  });

  @override
  List<Object?> get props => [group, groups];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
