import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static const _storage = FlutterSecureStorage();
  static const String _accessKey = 'accessToken';
  static const String _refreshKey = 'refreshToken';

  // Save both tokens
  static Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  // Clear tokens (Logout)
  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }

  // Get Access Token
  static Future<String?> getAccessToken() async {
    final accessToken = await _storage.read(key: _accessKey);
    return accessToken;
  }

  // Get Refresh Token
  static Future<String?> getRefreshToken() async {
    final refreshToken = await _storage.read(key: _refreshKey);
    return refreshToken;
  }
}