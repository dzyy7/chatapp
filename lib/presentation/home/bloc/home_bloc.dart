import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatapp/data/models/chat_group.dart';
import 'package:chatapp/data/repositories/chat_repository.dart';
import 'package:chatapp/presentation/home/bloc/home_event.dart';
import 'package:chatapp/presentation/home/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ChatRepository _chatRepository;
  List<ChatGroup> _groups = [];

  HomeBloc(this._chatRepository) : super(HomeInitial()) {
    on<HomeLoadGroupsEvent>(_onLoadGroups);
    on<HomeCreateGroupEvent>(_onCreateGroup);
    on<HomeDeleteGroupEvent>(_onDeleteGroup);
  }

  Future<void> _onLoadGroups(HomeLoadGroupsEvent event, Emitter<HomeState> emit) async {
    debugPrint('════════════════════════════════════════');
    debugPrint('🎯 HomeBloc - Load Groups');
    emit(HomeLoading());

    try {
      _groups = await _chatRepository.getMyGroups();
      debugPrint('✅ HomeBloc - Loaded ${_groups.length} groups');
      emit(HomeLoaded(groups: _groups));
    } catch (e) {
      debugPrint('💥 HomeBloc - Error loading groups: $e');
      emit(HomeError(message: e.toString()));
    }
    debugPrint('════════════════════════════════════════');
  }

  Future<void> _onCreateGroup(
    HomeCreateGroupEvent event,
    Emitter<HomeState> emit,
  ) async {
    debugPrint('════════════════════════════════════════');
    debugPrint('🎯 HomeBloc - Create Group Event');
    debugPrint('📝 Name: ${event.name}');

    emit(HomeGroupCreating(groups: _groups));

    try {
      final newGroup = await _chatRepository.createGroup(
        name: event.name,
        description: event.description,
        pin: event.pin,
      );

      _groups = [..._groups, newGroup];

      debugPrint('✅ HomeBloc - Group Created');
      emit(HomeGroupCreated(group: newGroup, groups: _groups));
    } catch (e) {
      debugPrint('💥 HomeBloc - Error: $e');
      emit(HomeError(message: e.toString()));
    }
    debugPrint('════════════════════════════════════════');
  }

  void _onDeleteGroup(HomeDeleteGroupEvent event, Emitter<HomeState> emit) {
    debugPrint('🎯 HomeBloc - Delete Group: ${event.group.name}');
    _groups = _groups.where((g) => g != event.group).toList();
    emit(HomeLoaded(groups: _groups));
  }
}
