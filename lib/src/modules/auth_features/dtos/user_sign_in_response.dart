class UserSignInResponse {
  final int userId;
  final String username;
  final String email;
  final String role;
  String accessToken; // The JWT
  String refreshToken;

  UserSignInResponse({
    required this.userId,
    required this.username,
    required this.email,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
  });

  // Factory constructor to create a User from the Backend JSON 'data' field
  factory UserSignInResponse.fromJson(Map<String, dynamic> json) {
    return UserSignInResponse(
      userId: json['userId'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'BUYER',
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }
}