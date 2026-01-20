import 'package:sneakerx/src/models/user.dart';

class UserSignInResponse {
  User user;
  String accessToken; // The JWT
  String refreshToken;

  UserSignInResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  // Factory constructor to create a User from the Backend JSON 'data' field
  factory UserSignInResponse.fromJson(Map<String, dynamic> json) {
    return UserSignInResponse(
      user: User.fromJson(json['user']),
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }
}