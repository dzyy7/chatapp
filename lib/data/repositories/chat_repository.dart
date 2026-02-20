// lib/data/repositories/chat_repository.dart

import '../services/api/chat_service.dart';
import '../models/group_model.dart';

class ChatRepository {
  final ChatService apiService;

  ChatRepository({required this.apiService});

  Future<GroupModel> createGroup(String name, String description, int pin) async {
    return await apiService.createGroup(name, description, pin);
  }
}