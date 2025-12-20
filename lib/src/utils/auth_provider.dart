import 'package:flutter/material.dart';
import 'package:sneakerx/src/modules/auth_features/dtos/user_sign_in_request.dart';
import 'package:sneakerx/src/modules/auth_features/dtos/user_sign_in_response.dart';
import 'package:sneakerx/src/services/auth_service.dart';
import 'package:sneakerx/src/services/user_service.dart';
import 'package:sneakerx/src/utils/api_client.dart';
import 'package:sneakerx/src/utils/token_manager.dart';

class AuthProvider extends ChangeNotifier {

  AuthProvider() {
    ApiClient.onTokenExpired = () {
      logout();
    };
  }

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  // INTERNAL STATE
  UserSignInResponse? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;

  // GETTERS (Public access)
  bool get isGuest => _currentUser == null; // Core check for Guest vs User
  bool get isLoading => _isLoading;
  UserSignInResponse? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  String? get token => _token;

  // --- ACTION: LOG IN ---
  Future<bool> login(UserSignInRequest request) async {
    _isLoading = true;
    _errorMessage = null; // Clear previous errors
    notifyListeners();

    try {
      final response = await _authService.signInUser(request);
      if(response.success && response.data != null) {
        _currentUser = response.data;

        // Save to Storage (Preferences)
        await TokenManager.saveTokens(_currentUser!.accessToken, _currentUser!.refreshToken);
        _isLoading = false;
        notifyListeners();

        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Handle Exceptions (Network error, 401, etc.)
      print("Login Exception: $e");
      _errorMessage = e.toString().replaceAll("Exception: ", ""); // Clean up "Exception: " text
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- ACTION: AUTO LOGIN (Check on App Start) ---
  Future<void> tryAutoLogin() async {
    _isLoading = true;
    _errorMessage = null; // Clear previous errors
    notifyListeners();

    try {
      final String? accessToken = await TokenManager.getAccessToken();
      final String? refreshToken = await TokenManager.getRefreshToken();
      if (accessToken == null || refreshToken == null) return;

      // 2. Verify with Server (Get fresh profile)
      // This ensures the token is actually valid and user isn't banned
      final response = await _userService.getCurrentUser();
      if(response.success && response.data != null) {
        _currentUser = response.data;
        String? refreshToken = await TokenManager.getRefreshToken();
        if(refreshToken == null) {
          return;
        }
        _currentUser!.refreshToken = refreshToken;
        _currentUser!.accessToken = accessToken;
        _token = accessToken;
        await TokenManager.saveTokens(accessToken, refreshToken);
      } else {
        await logout();
      }
    } catch (e) {
      print("Auto-login failed: $e");
      logout();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await TokenManager.clearTokens(); // Use helper
    notifyListeners();
  }


}