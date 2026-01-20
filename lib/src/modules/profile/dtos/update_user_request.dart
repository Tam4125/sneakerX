import 'dart:io';

import 'package:sneakerx/src/models/enums/user_status.dart';

class UpdateUserRequest {
  final int userId;
  final String username;
  final String fullName;
  final String email;
  final String phone;
  final String status;
  final String? avatarUrl;

  UpdateUserRequest({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.status,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'status': status,
      'avatarUrl': avatarUrl,
    };
  }

}