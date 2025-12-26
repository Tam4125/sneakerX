import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sneakerx/src/config/app_config.dart';
import 'package:sneakerx/src/modules/auth_features/dtos/user_sign_in_response.dart';
import 'package:sneakerx/src/utils/api_client.dart';
import 'package:sneakerx/src/utils/api_response.dart';
import 'package:sneakerx/src/modules/auth_features/dtos/user_register_request.dart';
import 'package:sneakerx/src/modules/auth_features/dtos/user_sign_in_request.dart';

class AuthService {
  static const String baseUrl = "${AppConfig.baseUrl}/auth";

  Future<ApiResponse<String>> registerUser(UserRegisterRequest request) async {
    final url = Uri.parse("$baseUrl/sign-up");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson())
      );

      // 1. Decode the JSON response
      Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse<String>(
          success: body['success'] ?? true,
          message: body['message'] ?? "Registration successful",
          data: body['data']
        );
      } else {
        return ApiResponse<String>(
          success: body['success'] ?? false,
          message: body['message'] ?? "Registration failed",
          data: body['data']
        );
      }

    } catch(e) {
      throw Exception("Failed to connect to server: $e");
    }
  }

  Future<ApiResponse<UserSignInResponse>> signInUser(UserSignInRequest request) async{
    final url = Uri.parse("$baseUrl/sign-in");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson())
      );

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
      throw Exception("Sign in failed: $e");
    }
  }

  Future<ApiResponse<String>> signOut(String refreshToken) async {
    final url = "$baseUrl/sign-out";

    try {
      final response = await ApiClient.post(
        url,
        {'refreshToken': refreshToken}
      );
      Map<String, dynamic> jsonMap = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse<String>(
          success: true,
          message: "Sign out successfully",
          data: ""
        );
      } else {
        Map<String, dynamic> errorMap = jsonDecode(response.body);

        return ApiResponse<String>(
            success: errorMap['success'] ?? false,
            message: errorMap['message'] ?? "Sign in failed",
            data: errorMap['data']
        );
      }

    } catch (e) {
      throw Exception("Sign Out failed: $e");
    }
  }

  Future<ApiResponse<UserSignInResponse>> refreshToken(String refreshToken) async {
    final url = Uri.parse("$baseUrl/refresh-token");
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken})
      );

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
    } catch(e) {
      throw Exception("Refresh token failed: $e");
    }
  }
}