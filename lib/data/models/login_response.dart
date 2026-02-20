class LoginResponse {
  final int statusCode;
  final String type;
  final String message;
  final LoginData? data;

  LoginResponse({
    required this.statusCode,
    required this.type,
    required this.message,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      statusCode: json['status_code'] ?? 0,
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
    );
  }

  bool get isSuccess => statusCode == 200;
}

class LoginData {
  final String authToken;
  final String type;
  final int expiresIn;

  LoginData({
    required this.authToken,
    required this.type,
    required this.expiresIn,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      authToken: json['authToken'] ?? '',
      type: json['type'] ?? 'Bearer',
      expiresIn: json['expiresIn'] ?? 0,
    );
  }
}
