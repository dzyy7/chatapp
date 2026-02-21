class ChatGroup {
  final String? id;
  final String name;
  final String description;
  final int pin;
  final DateTime? createdTime;

  ChatGroup({
    this.id,
    required this.name,
    required this.description,
    required this.pin,
    this.createdTime,
  });

  factory ChatGroup.fromJson(Map<String, dynamic> json) {
    return ChatGroup(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      pin: json['pin'] ?? 0,
      createdTime: json['createdTime'] != null
          ? DateTime.tryParse(json['createdTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pin': pin,
      'createdTime': createdTime?.toIso8601String(),
    };
  }

  ChatGroup copyWith({
    String? id,
    String? name,
    String? description,
    int? pin,
    DateTime? createdTime,
  }) {
    return ChatGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      pin: pin ?? this.pin,
      createdTime: createdTime ?? this.createdTime,
    );
  }
}
