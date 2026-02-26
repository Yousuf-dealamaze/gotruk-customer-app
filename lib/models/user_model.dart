class LoginResponse {
  final bool success;
  final int code;
  final String message;
  final LoginData data;

  LoginResponse({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: LoginData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'code': code,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class LoginData {
  final String id;
  final String displayId;
  final String email;
  final String role;
  final String accessToken;
  final String refreshToken;

  LoginData({
    required this.id,
    required this.displayId,
    required this.email,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      id: json['id'] ?? '',
      displayId: json['displayId'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayId': displayId,
      'email': email,
      'role': role,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}
