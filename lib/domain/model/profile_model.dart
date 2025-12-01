// lib\domain\model\profile_model.dart
class ProfileModel {
  final String id;
  final String userId;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final int level;
  final int currentXP;
  final int xpToNextLevel;

  ProfileModel({
    required this.id,
    required this.userId,
    required this.email,
    this.fullName,
    this.avatarUrl,
    required this.level,
    required this.currentXP,
    required this.xpToNextLevel,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id']?.toString() ?? '', 
      userId: json["user_id"]?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      level: (json['level'] as int?) ?? 1,
      currentXP: (json['current_xp'] as int?) ?? 0,
      xpToNextLevel: (json['xp_to_next_level'] as int?) ?? 100,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'level': level,
      'current_xp': currentXP,
      'xp_to_next_level': xpToNextLevel,
    };
  }

  // Helper method untuk progress percentage
  double get progressPercentage {
    if (xpToNextLevel == 0) return 0.0;
    return currentXP / xpToNextLevel;
  }

  // Helper untuk menampilkan XP
  String get xpDisplay => '$currentXP/$xpToNextLevel XP';
}