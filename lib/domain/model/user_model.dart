class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? username;
  final String? phoneNumber;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.username,
    this.phoneNumber,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? json['fullname']?.toString(),
      username: json['username']?.toString(),
      phoneNumber:
          json['phone_number']?.toString() ?? json['phoneNumber']?.toString(),
      avatarUrl:
          json['avatar_url']?.toString() ?? json['avatarUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'username': username,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
    };
  }
}
