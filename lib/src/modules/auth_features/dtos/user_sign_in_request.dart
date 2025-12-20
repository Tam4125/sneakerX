class UserSignInRequest {
  final String identifier;
  final String password;
  UserSignInRequest({
    required this.identifier,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'password': password
    };
  }
}