// lib/data/services/api/chat_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/group_model.dart';

class ChatService {
  // Ganti dengan Base URL API aslimu
  final String baseUrl = "https://api.domainkamu.com"; 

  Future<GroupModel> createGroup(String name, String description, int pin) async {
    final url = Uri.parse('$baseUrl/admin/group/create');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'description': description,
        'pin': pin,
      }),
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      // Mengambil bagian "data" dari struktur response aslimu
      return GroupModel.fromJson(jsonBody['data']);
    } else {
      // Menangkap pesan error dari server jika ada
      throw Exception('Gagal membuat grup. Silakan coba lagi.');
    }
  }
}