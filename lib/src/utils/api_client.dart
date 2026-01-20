import 'dart:io';
import 'package:dio/dio.dart';
import 'package:sneakerx/src/config/app_config.dart';
import 'package:sneakerx/src/services/auth_service.dart';
import 'package:sneakerx/src/utils/token_manager.dart';


// Interceptors: No more manual if (status == 401) checks in every method. The interceptor handles it globally.
// FormData: Dio handles multipart uploads much cleaner than http.
// Automatic Retry: If the token refreshes successfully, Dio automatically replays the failed request.

class ApiClient {
  // Callback to force logout if refresh fails
  static Function? onTokenExpired;

  // 1. Setup Dio Instance (Singleton-like)
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(_AuthInterceptor());

  // --- GENERIC METHODS ---
  static Future<Response> get(String url) async {
    return _dio.get(url);
  }

  static Future<Response> post(String url, Map<String, dynamic> body) async {
    return _dio.post(url, data: body);
  }

  static Future<Response> put(String url, Map<String, dynamic>? body) async {
    return _dio.put(url, data: body);
  }

  static Future<Response> delete(String url, Map<String, dynamic>? body) async {
    return _dio.delete(url, data: body);
  }

  // --- ROBUST MULTIPART POST ---
  static Future<Response> postMultipart({
    required String url,
    Map<String, String>? fields,
    List<File>? files,
    File? file,
    required String fileField,
  }) async {
    // Convert generic map + files to Dio FormData
    FormData formData = FormData();
    if(fields != null) {
      formData = FormData.fromMap(fields);
    }

    // 1. Handle Single File (Convenience param)
    if (file != null && await file.exists()) {
      String fileName = file.path.split('/').last;
      formData.files.add(MapEntry(
        fileField,
        await MultipartFile.fromFile(file.path, filename: fileName),
      ));
    }

    // 2. Handle List of Files
    if (files != null && files.isNotEmpty) {
      for (var f in files) {
        if (await f.exists()) {
          String fileName = f.path.split('/').last;
          formData.files.add(MapEntry(
            fileField,
            await MultipartFile.fromFile(f.path, filename: fileName),
          ));
        }
      }
    }

    return _dio.post(url, data: formData);
  }

  // --- ROBUST MULTIPART PUT (List of Files) ---
  static Future<Response> putMultipart({
    required String url,
    required Map<String, String> fields,
    List<File>? files,
    File? file,
    required String fileField,
  }) async {
    final formData = FormData.fromMap(fields);

    // 1. Handle Single File (Convenience param)
    if (file != null && await file.exists()) {
      String fileName = file.path.split('/').last;
      formData.files.add(MapEntry(
        fileField,
        await MultipartFile.fromFile(file.path, filename: fileName),
      ));
    }

    // 2. Handle List of Files
    if (files != null && files.isNotEmpty) {
      for (var f in files) {
        if (await f.exists()) {
          String fileName = f.path.split('/').last;
          formData.files.add(MapEntry(
            fileField,
            await MultipartFile.fromFile(f.path, filename: fileName),
          ));
        }
      }
    }

    return _dio.put(url, data: formData);
  }
}

// --- THE INTERCEPTOR ---
class _AuthInterceptor extends Interceptor {
  // Lock to prevent multiple refreshes at once
  bool _isRefreshing = false;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Automatically add the token to every request
    final token = await TokenManager.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if error is 401 Unauthorized
    if (err.response?.statusCode == 401) {

      // Prevent infinite loops if the refresh endpoint itself returns 401
      if (err.requestOptions.path.contains('/auth/refresh-token')) {
        ApiClient.onTokenExpired?.call();
        return handler.next(err);
      }

      if (!_isRefreshing) {
        _isRefreshing = true;
        try {
          final newAccessToken = await _attemptRefreshToken();
          if (newAccessToken != null) {
            _isRefreshing = false;

            // Update the header of the failed request with new token
            err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            // Retry the request using the *same* Dio instance
            final opts = Options(
              method: err.requestOptions.method,
              headers: err.requestOptions.headers,
            );

            final cloneReq = await ApiClient._dio.request(
              err.requestOptions.path,
              options: opts,
              data: err.requestOptions.data,
              queryParameters: err.requestOptions.queryParameters,
            );

            return handler.resolve(cloneReq);
          }
        } catch (e) {
          // Refresh failed
          _isRefreshing = false;
        }
      }

      // If refresh failed or logic skipped, trigger logout
      ApiClient.onTokenExpired?.call();
    }
    return handler.next(err);
  }

  Future<String?> _attemptRefreshToken() async {
    try {
      final refreshToken = await TokenManager.getRefreshToken();
      if (refreshToken == null) return null;

      // Use a separate/clean call for refresh to avoid interceptor loops
      // Assuming AuthService has a method that returns the raw tokens
      final authService = AuthService();
      final apiResponse = await authService.refreshToken(refreshToken);

      if (apiResponse.success && apiResponse.data != null) {
        await TokenManager.saveTokens(
          apiResponse.data!.accessToken,
          apiResponse.data!.refreshToken,
        );
        return apiResponse.data!.accessToken;
      }
    } catch (e) {
      print("Refresh token failed: $e");
    }
    return null;
  }
}