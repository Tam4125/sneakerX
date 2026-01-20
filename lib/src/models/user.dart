import 'package:sneakerx/src/models/enums/user_status.dart';

class User {
  final int userId;
  final String username;
  final String? fullName;
  final String email;
  final String phone;
  final String role;
  final String avatarUrl;
  final UserStatus status;
  final DateTime createdAt;

  User({
    required this.userId,
    required this.username,
    this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.avatarUrl,
    required this.status,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      username: json['username'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'] ?? "BUYER",
      avatarUrl: json['avatarUrl'],
      status: UserStatus.values.byName(json['status'] ?? "ACTIVE"),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}