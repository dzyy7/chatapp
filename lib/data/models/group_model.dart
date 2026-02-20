// lib/data/models/group_model.dart

class GroupModel {
  final String id;
  final String name;
  final String description;
  final int pin;
  final DateTime? createdTime;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.pin,
    this.createdTime,
  });

  // Mapping dari JSON ke Object Dart
  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      pin: json['pin'] ?? 0,
      createdTime: json['createdTime'] != null 
          ? DateTime.parse(json['createdTime']) 
          : null,
    );
  }
}