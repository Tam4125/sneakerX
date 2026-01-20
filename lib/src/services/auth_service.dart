import 'package:dio/dio.dart';
import 'package:sneakerx/src/config/app_config.dart';
import 'package:sneakerx/src/models/user.dart';
import 'package:sneakerx/src/modules/auth_features/dtos/user_sign_in_response.dart';
import 'package:sneakerx/src/utils/api_client.dart';
import 'package:sneakerx/src/utils/api_response.dart';
import 'package:sneakerx/src/modules/auth_features/dtos/user_register_request.dart';
import 'package:sneakerx/src/modules/auth_features/dtos/user_sign_in_request.dart';

class AuthService {
  static const String _authPath = "/auth";

  Future<ApiResponse<User>> registerUser(UserRegisterRequest request) async {
    final endpoint = "$_authPath/sign-up";
    try {
      final response = await ApiClient.post(
        endpoint,
        request.toJson()
      );

      return ApiResponse.fromJson(
        response.data,
          (data) => User.fromJson(data as Map<String, dynamic>)
      );

    } on DioException catch(e) {
      return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? "Registration failed",
          data: null
      );
    }
  }

  Future<ApiResponse<UserSignInResponse>> signInUser(UserSignInRequest request) async{
    final endpoint = "$_authPath/sign-in";

    try {
      final response = await ApiClient.post(
        endpoint,
        request.toJson()
      );

      return ApiResponse<UserSignInResponse>.fromJson(
        response.data,
          (data) => UserSignInResponse.fromJson(data as Map<String, dynamic>)
      );
    } on DioException catch (e) {
      return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? "Sign in failed",
          data: null
      );
    }
  }

  Future<ApiResponse<String>> signOut(String refreshToken) async {
    final url = "$_authPath/sign-out";

    try {
      final response = await ApiClient.post(
        url,
        {'refreshToken': refreshToken}
      );

      return ApiResponse<String>(
        success: true,
        message: "Sign out successfully",
        data: ""
      );

    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? "Sign out failed",
        data: null
      );
    }
  }

  Future<ApiResponse<UserSignInResponse>> refreshToken(String refreshToken) async {
    final url = "${AppConfig.baseUrl}$_authPath/refresh-token";
    final rawDio = Dio();
    
    try {
      final response = await rawDio.post(
        url,
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'Content-Type': 'application/json'}
        )
      );

      return ApiResponse<UserSignInResponse>.fromJson(
        response.data,
          (data) => UserSignInResponse.fromJson(data as Map<String, dynamic>)
      );
    } on DioException catch(e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? "Session expired",
        data: null
      );
    }
  }
}