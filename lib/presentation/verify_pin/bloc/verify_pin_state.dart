import 'package:equatable/equatable.dart';

abstract class VerifyPinState extends Equatable {
  const VerifyPinState();

  @override
  List<Object?> get props => [];
}

class VerifyPinInitial extends VerifyPinState {}

class VerifyPinLoading extends VerifyPinState {}

class VerifyPinSuccess extends VerifyPinState {
  final String groupId;

  const VerifyPinSuccess({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

class VerifyPinError extends VerifyPinState {
  final String message;

  const VerifyPinError({required this.message});

  @override
  List<Object?> get props => [message];
}
