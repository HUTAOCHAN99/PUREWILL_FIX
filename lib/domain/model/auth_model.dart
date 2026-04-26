// lib/data/models/auth_model.dart

class RegisterRequest {
  final String email;
  final String username;
  final String fullname;
  final String gender;
  final DateTime birthDate;
  final String password;
  final String passwordConfirmation;
  
  RegisterRequest({
    required this.email,
    required this.username,
    required this.fullname,
    required this.gender,
    required this.birthDate,
    required this.password,
    required this.passwordConfirmation,
  });
  
  Map<String, dynamic> toJson() => {
    'email': email,
    'username': username,
    'fullname': fullname,
    'gender': gender,
    'birthDate': birthDate.toIso8601String(),
    'password': password,
    'passwordConfirmation': passwordConfirmation,
  };
}

class UserData {
  final int id;
  final String email;
  final String username;
  
  UserData({required this.id, required this.email, required this.username});
  
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      email: json['email'],
      username: json['username'],
    );
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => message;
}