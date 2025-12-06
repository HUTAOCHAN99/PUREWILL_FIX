// lib\domain\model\community_model.dart
import 'package:flutter/material.dart';

class Community {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final String color;
  final String? coverImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int memberCount;
  final String? adminId;
  final int? categoryId;
  final List<String> rules;
  final List<String> tags;
  final bool isJoined;
  final String? userRole;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.color,
    this.coverImageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.memberCount,
    this.adminId,
    this.categoryId,
    required this.rules,
    required this.tags,
    this.isJoined = false,
    this.userRole,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      iconName: json['icon_name'] as String? ?? 'people',
      color: json['color'] as String? ?? '#7C3AED',
      coverImageUrl: json['cover_image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      memberCount: json['member_count'] as int? ?? 0,
      adminId: json['admin_id'] as String?,
      categoryId: json['category_id'] as int?,
      rules: (json['rules'] is List ? json['rules'] : [])
          .map((e) => e.toString())
          .toList(),
      tags: (json['tags'] is List ? json['tags'] : [])
          .map((e) => e.toString())
          .toList(),
      isJoined: json['is_joined'] as bool? ?? false,
      userRole: json['user_role'] as String?,
    );
  }

  // Add copyWith method
  Community copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    String? color,
    String? coverImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? memberCount,
    String? adminId,
    int? categoryId,
    List<String>? rules,
    List<String>? tags,
    bool? isJoined,
    String? userRole,
  }) {
    return Community(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      memberCount: memberCount ?? this.memberCount,
      adminId: adminId ?? this.adminId,
      categoryId: categoryId ?? this.categoryId,
      rules: rules ?? this.rules,
      tags: tags ?? this.tags,
      isJoined: isJoined ?? this.isJoined,
      userRole: userRole ?? this.userRole,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_name': iconName,
      'color': color,
      'cover_image_url': coverImageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
      'member_count': memberCount,
      'admin_id': adminId,
      'category_id': categoryId,
      'rules': rules,
      'tags': tags,
    };
  }

  IconData get icon {
    switch (iconName) {
      case 'fitness_center':
        return Icons.fitness_center;
      case 'psychology':
        return Icons.psychology;
      case 'restaurant':
        return Icons.restaurant;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'work':
        return Icons.work;
      case 'menu_book':
        return Icons.menu_book;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'school':
        return Icons.school;
      default:
        return Icons.people;
    }
  }

  Color get colorValue {
    try {
      return Color(int.parse(color.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF7C3AED);
    }
  }
}

class CommunityPost {
  final String id;
  final String communityId;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final bool isEdited;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;

  CommunityPost({
    required this.id,
    required this.communityId,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.isPinned,
    required this.isEdited,
    required this.likesCount,
    required this.commentsCount,
    this.isLiked = false,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] as String,
      communityId: json['community_id'] as String,
      authorId: json['author_id'] as String,
      authorName: (json['profiles']?['full_name'] as String?) ?? 'Anonymous',
      authorAvatar: json['profiles']?['avatar_url'] as String?,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isPinned: json['is_pinned'] as bool? ?? false,
      isEdited: json['is_edited'] as bool? ?? false,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'community_id': communityId,
      'author_id': authorId,
      'content': content,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_pinned': isPinned,
      'is_edited': isEdited,
    };
  }
}

class CommunityComment {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? parentCommentId;
  final bool isDeleted;

  CommunityComment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.parentCommentId,
    this.isDeleted = false,
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    return CommunityComment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      authorId: json['author_id'] as String,
      authorName: (json['profiles']?['full_name'] as String?) ?? 'Anonymous',
      authorAvatar: json['profiles']?['avatar_url'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      parentCommentId: json['parent_comment_id'] as String?,
      isDeleted: json['deleted_at'] != null,
    );
  }
}