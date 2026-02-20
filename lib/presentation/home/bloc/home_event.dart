// lib/presentation/home/bloc/home_event.dart

abstract class HomeEvent {}

class CreateGroupEvent extends HomeEvent {
  final String name;
  final String description;
  final int pin;

  CreateGroupEvent({
    required this.name,
    required this.description,
    required this.pin,
  });
}