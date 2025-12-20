import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sneakerx/src/services/auth_service.dart';
import 'package:sneakerx/src/utils/token_manager.dart';

class ApiClient {
  // Callback to force logout if refresh fails
  static Function? onTokenExpired;

  // Generic GET method
  static Future<http.Response> get(String url) async {
    String? token = await TokenManager.getAccessToken();

    // 1. Initial Request
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    // 2. Check for 401 (Unauthorized)
    if (response.statusCode == 401) {
      return await _handleRefreshAndRetry(() => get(url));
    }

    return response;
  }

  // Generic POST method
  static Future<http.Response> post(String url, Map<String, dynamic> body) async {
    String? token = await TokenManager.getAccessToken();

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      return await _handleRefreshAndRetry(() => post(url, body));
    }

    return response;
  }

  // --- HELPER: Handle Refresh Logic ---
  static Future<http.Response> _handleRefreshAndRetry(Future<http.Response> Function() retryRequest) async {
    print("AccessToken expired. Attempting refresh...");

    // 1. Get Refresh Token
    final refreshToken = await TokenManager.getRefreshToken();
    if (refreshToken == null) {
      _triggerLogout();
      return http.Response('{"message": "Session expired"}', 401);
    }

    try {
      // 2. Call Auth Service to get new tokens
      final authService = AuthService();
      final apiResponse = await authService.refreshToken(refreshToken);

      if (apiResponse.success && apiResponse.data != null) {
        // 3. Save new tokens
        await TokenManager.saveTokens(
            apiResponse.data!.accessToken,
            apiResponse.data!.refreshToken
        );
        print("Refresh successful. Retrying original request...");

        // 4. RETRY the original request (Recursive call)
        return await retryRequest();
      } else {
        _triggerLogout();
        return http.Response('{"message": "Refresh failed"}', 401);
      }
    } catch (e) {
      print("Refresh Error: $e");
      _triggerLogout();
      return http.Response('{"message": "Session expired"}', 401);
    }
  }

  static void _triggerLogout() {
    print("Session completely expired. Logging out.");
    if (onTokenExpired != null) {
      onTokenExpired!();
    }
  }
}