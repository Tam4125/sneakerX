import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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

  // Generic DELETE method
  static Future<http.Response> delete(String url, Map<String, dynamic>? body) async {
    String? token = await TokenManager.getAccessToken();

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode == 401) {
      return await _handleRefreshAndRetry(() => delete(url, body));
    }

    return response;
  }

  // Generic PUT method
  static Future<http.Response> put(String url, Map<String, dynamic>? body) async {
    String? token = await TokenManager.getAccessToken();

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode == 401) {
      // Recursively retry the PUT request after refreshing the token
      return await _handleRefreshAndRetry(() => put(url, body));
    }

    return response;
  }

  // Robust Multipart POST
  static Future<http.Response> postMultipart({
    required String url,
    required Map<String, String> fields,
    required List<File> files,
    required String fileField,
  }) async {
    String? token = await TokenManager.getAccessToken();

    // 1. Build the Multipart Request
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // 2. Add Headers
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // 3. Add Text Fields
    request.fields.addAll(fields);

    // 4. Add Files (Create fresh streams every time this method is called)
    for (var file in files) {
      if (await file.exists()) {
        request.files.add(await http.MultipartFile.fromPath(
          fileField,
          file.path,
        ));
      }
    }

    // 5. Send & Convert
    // We convert StreamedResponse to standard Response to handle 401 easier
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // 6. Check for 401 and Retry
      if (response.statusCode == 401) {
        return await _handleRefreshAndRetry(() => postMultipart(
          url: url,
          fields: fields,
          files: files, // We pass the original File objects, so retry works!
          fileField: fileField,
        ));
      }

      return response;
    } catch (e) {
      // Network errors during upload
      throw Exception("Upload failed: $e");
    }
  }

  // Robust Multipart POST (File is now Optional)
  static Future<http.Response> postMultipartOneImage({
    required String url,
    required Map<String, String> fields,
    File? file, // 1. Remove 'required' and make it nullable
    required String fileField,
  }) async {
    String? token = await TokenManager.getAccessToken();

    // 1. Build the Multipart Request
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // 2. Add Headers
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // 3. Add Text Fields
    request.fields.addAll(fields);

    // 4. Add File ONLY if it is not null
    if (file != null) {
      request.files.add(await http.MultipartFile.fromPath(
        fileField,
        file.path,
      ));
    }

    // 5. Send & Convert
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // 6. Check for 401 and Retry
      if (response.statusCode == 401) {
        return await _handleRefreshAndRetry(() => postMultipartOneImage(
          url: url,
          fields: fields,
          file: file, // Pass the nullable file
          fileField: fileField,
        ));
      }

      return response;
    } catch (e) {
      throw Exception("Upload failed: $e");
    }
  }

  // Robust Multipart POST (File is now Optional)
  static Future<http.Response> putMultipartOneImage({
    required String url,
    required Map<String, String> fields,
    File? file,
    required String fileField,
  }) async {
    String? token = await TokenManager.getAccessToken();

    // 1. Build the Multipart Request
    var request = http.MultipartRequest('PUT', Uri.parse(url));

    // 2. Add Headers
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // 3. Add Text Fields
    request.fields.addAll(fields);

    // 4. Add File ONLY if it is not null
    if (file != null) {
      request.files.add(await http.MultipartFile.fromPath(
        fileField,
        file.path,
      ));
    }

    // 5. Send & Convert
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // 6. Check for 401 and Retry
      if (response.statusCode == 401) {
        return await _handleRefreshAndRetry(() => putMultipartOneImage(
          url: url,
          fields: fields,
          file: file, // Pass the nullable file
          fileField: fileField,
        ));
      }

      return response;
    } catch (e) {
      throw Exception("Upload failed: $e");
    }
  }


  // Robust Multipart PUT
  static Future<http.Response> putMultipart({
    required String url,
    required Map<String, String> fields,
    required List<File> files,
    required String fileField,
  }) async {
    String? token = await TokenManager.getAccessToken();

    // 1. Build the Multipart Request
    var request = http.MultipartRequest('PUT', Uri.parse(url));

    // 2. Add Headers
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // 3. Add Text Fields
    request.fields.addAll(fields);

    // 4. Add Files (Create fresh streams every time this method is called)
    for (var file in files) {
      if (await file.exists()) {
        request.files.add(await http.MultipartFile.fromPath(
          fileField,
          file.path,
        ));
      }
    }

    // 5. Send & Convert
    // We convert StreamedResponse to standard Response to handle 401 easier
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // 6. Check for 401 and Retry
      if (response.statusCode == 401) {
        return await _handleRefreshAndRetry(() => putMultipart(
          url: url,
          fields: fields,
          files: files, // We pass the original File objects, so retry works!
          fileField: fileField,
        ));
      }

      return response;
    } catch (e) {
      // Network errors during upload
      throw Exception("Upload failed: $e");
    }
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
        print("Save access token: ${apiResponse.data!.accessToken}\nSave refresh token: ${apiResponse.data!.refreshToken}");
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