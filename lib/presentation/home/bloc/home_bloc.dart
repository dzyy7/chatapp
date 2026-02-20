// lib/presentation/home/bloc/home_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/chat_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ChatRepository chatRepository;

  HomeBloc({required this.chatRepository}) : super(HomeInitial()) {
    on<CreateGroupEvent>(_onCreateGroup);
  }

  Future<void> _onCreateGroup(CreateGroupEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading()); // Trigger UI untuk loading
    
    try {
      final newGroup = await chatRepository.createGroup(
        event.name, 
        event.description, 
        event.pin,
      );
      
      emit(HomeCreateGroupSuccess(newGroup, "Grup berhasil dibuat!"));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}