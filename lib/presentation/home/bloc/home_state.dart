// lib/presentation/home/bloc/home_state.dart

import '../../../data/models/group_model.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeCreateGroupSuccess extends HomeState {
  final GroupModel newGroup;
  final String message;

  HomeCreateGroupSuccess(this.newGroup, this.message);
}

class HomeError extends HomeState {
  final String errorMessage;

  HomeError(this.errorMessage);
}