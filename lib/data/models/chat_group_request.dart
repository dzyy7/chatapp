class ChatGroupRequest {
  final String name;
  final String description;
  final int pin;

  ChatGroupRequest({
    required this.name,
    required this.description,
    required this.pin,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'pin': pin,
    };
  }
}
