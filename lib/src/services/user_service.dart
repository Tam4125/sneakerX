import 'dart:convert';

import 'package:sneakerx/src/modules/auth_features/dtos/user_sign_in_response.dart';
import 'package:sneakerx/src/utils/api_client.dart';
import 'package:sneakerx/src/utils/api_response.dart';

class UserService {
  static const String baseUrl = "http://10.0.2.2:8080/users";

  Future<ApiResponse<UserSignInResponse>> getCurrentUser() async {
    String url = "$baseUrl/me";
    try {
      final response = await ApiClient.get(url);
      Map<String, dynamic> jsonMap = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse<UserSignInResponse>.fromJson(
          jsonMap,
              (data) => UserSignInResponse.fromJson(data as Map<String, dynamic>),
        );
      } else {
        Map<String, dynamic> errorMap = jsonDecode(response.body);

        return ApiResponse<UserSignInResponse>(
            success: errorMap['success'] ?? false,
            message: errorMap['message'] ?? "Sign in failed",
            data: errorMap['data']
        );
      }
    } catch (e) {
      throw Exception("Get current user failed: $e");
    }
  }
}