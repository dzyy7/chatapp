class VerifyPinResponse {
  final int statusCode;
  final String type;
  final String message;
  final VerifyPinData? data;

  VerifyPinResponse({
    required this.statusCode,
    required this.type,
    required this.message,
    this.data,
  });

  factory VerifyPinResponse.fromJson(Map<String, dynamic> json) {
    if (json['detail'] != null) {
      final detail = json['detail'] as Map<String, dynamic>;
      return VerifyPinResponse(
        statusCode: detail['status_code'] ?? 400,
        type: detail['type'] ?? '',
        message: detail['message'] ?? 'Terjadi kesalahan',
        data: null,
      );
    }

    return VerifyPinResponse(
      statusCode: json['status_code'] ?? 0,
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] != null ? VerifyPinData.fromJson(json['data']) : null,
    );
  }

  bool get isSuccess => statusCode == 200 && data?.verified == true;
}

class VerifyPinData {
  final bool verified;
  final String groupId;

  VerifyPinData({
    required this.verified,
    required this.groupId,
  });

  factory VerifyPinData.fromJson(Map<String, dynamic> json) {
    return VerifyPinData(
      verified: json['verified'] ?? false,
      groupId: json['groupId'] ?? '',
    );
  }
}
