class User {
  final int userId;
  final String username;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String avatarUrl;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool enabled;

  User({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.avatarUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.enabled,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      username: json['username'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      avatarUrl: json['avatarUrl'],
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      enabled: json['enabled'],
    );
  }
}