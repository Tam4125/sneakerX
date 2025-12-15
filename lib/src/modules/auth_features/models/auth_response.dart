class AuthResponse {
  final bool success;
  final String message;
  final dynamic data;

  AuthResponse({
    required this.success,
    required this.message,
    required this.data,
  });
}