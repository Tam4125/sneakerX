class UserRegisterRequest {
  final String username;
  final String email;
  final String phone;
  final String password;

  UserRegisterRequest({
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
  });

  // Converts the object to a JSON Map for the API
  Map<String, dynamic> toJson() {
    return {
      'username':username,
      'email':email,
      'phone':phone,
      'password':password,
    };
  }
}