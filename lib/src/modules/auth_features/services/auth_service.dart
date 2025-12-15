import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sneakerX/src/modules/auth_features/models/auth_response.dart';
import 'package:sneakerX/src/modules/auth_features/models/user_register_request.dart';
import 'package:sneakerX/src/modules/auth_features/models/user_sign_in_request.dart';

class AuthService {

  static const String baseUrl = "http://10.0.2.2:8080/auth";

  Future<AuthResponse> registerUser(UserRegisterRequest request) async {
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
        return AuthResponse(
          success: body['success'] ?? true,
          message: body['message'] ?? "Registration successful",
          data: body['data']
        );
      } else {
        return AuthResponse(
          success: body['success'] ?? false,
          message: body['message'] ?? "Registration failed",
          data: body['data']
        );
      }

    } catch(e) {
      throw Exception("Failed to connect to server: $e");
    }
  }

  Future<AuthResponse> signInUser(UserSignInRequest request) async{
    final url = Uri.parse("$baseUrl/sign-in");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson())
      );

      Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse(
          success: body['success'] ?? true,
          message: body['message'] ?? "Sign in successful",
          data: body['data']
        );
      } else {
        return AuthResponse(
          success: body['success'] ?? false,
          message: body['message'] ?? "Sign in failed",
          data: body['data']
        );
      }


    } catch (e) {
      throw Exception("Sign in failed: $e");
    }
  }
}