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
  final int pin;

  const VerifyPinSuccess({required this.groupId, required this.pin});

  @override
  List<Object?> get props => [groupId, pin];
}

class VerifyPinError extends VerifyPinState {
  final String message;

  const VerifyPinError({required this.message});

  @override
  List<Object?> get props => [message];
}
