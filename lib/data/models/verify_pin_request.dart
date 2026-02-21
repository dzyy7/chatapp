class VerifyPinRequest {
  final String groupId;
  final int pin;

  VerifyPinRequest({required this.groupId, required this.pin});

  Map<String, dynamic> toJson() {
    return {'groupId': groupId, 'pin': pin};
  }
}
