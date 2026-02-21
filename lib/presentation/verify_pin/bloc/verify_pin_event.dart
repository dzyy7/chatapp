import 'package:equatable/equatable.dart';

abstract class VerifyPinEvent extends Equatable {
  const VerifyPinEvent();

  @override
  List<Object?> get props => [];
}

class VerifyPinSubmitEvent extends VerifyPinEvent {
  final String groupId;
  final int pin;

  const VerifyPinSubmitEvent({
    required this.groupId,
    required this.pin,
  });

  @override
  List<Object?> get props => [groupId, pin];
}
