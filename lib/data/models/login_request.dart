class LoginRequest {
  final String nonce;

  LoginRequest({this.nonce = '1234567890'});

  Map<String, dynamic> toJson() {
    return {
      'nonce': nonce,
    };
  }
}
