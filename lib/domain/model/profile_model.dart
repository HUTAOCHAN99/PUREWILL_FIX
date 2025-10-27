class ProfileModel {
  final String id;
  final String userId;
  final String email;
  final String? fullName;
  final String? avatarUrl;

  ProfileModel({
    required this.id,
    required this.userId,
    required this.email,
    this.fullName,
    this.avatarUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id']?.toString() ?? '', 
      userId: json["user_id"]?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'full_name': fullName, 'avatar_url': avatarUrl};
  }
}