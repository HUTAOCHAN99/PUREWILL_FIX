import 'dart:convert';

class CategoryModel {
  final int id;
  final String name;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    DateTime parseCreatedAt(dynamic date) {
      if (date is String) {
        return DateTime.parse(date);
      }
      return DateTime.now();
    }

    return CategoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'Unknown',
      createdAt: parseCreatedAt(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'CategoryModel{id: $id, name: $name}';
  }
}

class Community {
  final String id;
  final String name;
  final String? description;
  final String? iconName;
  final String? color;
  final String? coverImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final int memberCount;
  final String? adminId;
  final int? categoryId;
  final List<String>? rules;
  final List<String>? tags;
  final bool isJoined;
  final bool? isMember;
  final CategoryModel? category;

  Community({
    required this.id,
    required this.name,
    this.description,
    this.iconName,
    this.color,
    this.coverImageUrl,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.memberCount = 0,
    this.adminId,
    this.categoryId,
    this.rules,
    this.tags,
    this.isJoined = false,
    this.isMember,
    this.category,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic list) {
      if (list is List) {
        return list.map((e) => e.toString()).toList();
      }
      return [];
    }

    // Handle profiles jika berupa list atau map
    CategoryModel? parseCategory(dynamic categoryData) {
      if (categoryData == null) return null;
      if (categoryData is List && categoryData.isNotEmpty) {
        return CategoryModel.fromJson(categoryData[0] as Map<String, dynamic>);
      } else if (categoryData is Map<String, dynamic>) {
        return CategoryModel.fromJson(categoryData);
      }
      return null;
    }

    return Community(
      id: json['id'].toString(),
      name: json['name'].toString(),
      description: json['description']?.toString(),
      iconName: json['icon_name']?.toString(),
      color: json['color']?.toString() ?? '#7C3AED',
      coverImageUrl: json['cover_image_url']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
      isActive: json['is_active'] as bool? ?? true,
      memberCount: (json['member_count'] as int?) ?? 0,
      adminId: json['admin_id']?.toString(),
      categoryId: json['category_id'] is int ? json['category_id'] : 
          int.tryParse(json['category_id'].toString()),
      rules: parseList(json['rules']),
      tags: parseList(json['tags']),
      isJoined: json['is_joined'] as bool? ?? false,
      isMember: json['is_member'] as bool?,
      category: parseCategory(json['categories']),
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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
      'member_count': memberCount,
      'admin_id': adminId,
      'category_id': categoryId,
      'rules': rules,
      'tags': tags,
      'is_joined': isJoined,
    };
  }

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
    bool? isMember,
    CategoryModel? category,
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
      isMember: isMember ?? this.isMember,
      category: category ?? this.category,
    );
  }

  @override
  String toString() {
    return 'Community{id: $id, name: $name, members: $memberCount, isJoined: $isJoined}';
  }
}

class Profile {
  final String? id;
  final String? userId;
  final String? fullName;
  final String? avatarUrl;
  final int? level;
  final int? currentXp;
  final int? xpToNextLevel;

  Profile({
    this.id,
    this.userId,
    this.fullName,
    this.avatarUrl,
    this.level,
    this.currentXp,
    this.xpToNextLevel,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      fullName: json['full_name']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      level: (json['level'] as int?) ?? 1,
      currentXp: (json['current_xp'] as int?) ?? 0,
      xpToNextLevel: (json['xp_to_next_level'] as int?) ?? 100,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'level': level,
      'current_xp': currentXp,
      'xp_to_next_level': xpToNextLevel,
    };
  }
}

class CommunityPost {
  final String id;
  final String communityId;
  final String authorId;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final bool isEdited;
  final DateTime? deletedAt;
  final int likesCount;
  final int commentsCount;
  final int shareCount;
  final int viewCount;
  final String? sharedFromPostId;
  final String? sharedFromCommunityId;
  final Profile? author;
  final bool? isLikedByUser;
  final bool? isViewedByUser;
  final Community? community;
  final List<CommunityComment>? comments;

  CommunityPost({
    required this.id,
    required this.communityId,
    required this.authorId,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.isEdited = false,
    this.deletedAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.shareCount = 0,
    this.viewCount = 0,
    this.sharedFromPostId,
    this.sharedFromCommunityId,
    this.author,
    this.isLikedByUser,
    this.isViewedByUser,
    this.community,
    this.comments,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    // Handle author profiles yang bisa berupa list atau map
    Profile? parseAuthor(dynamic profilesData) {
      if (profilesData == null) return null;
      if (profilesData is List && profilesData.isNotEmpty) {
        return Profile.fromJson(profilesData[0] as Map<String, dynamic>);
      } else if (profilesData is Map<String, dynamic>) {
        return Profile.fromJson(profilesData);
      }
      return null;
    }

    // Handle community data
    Community? parseCommunity(dynamic communityData) {
      if (communityData == null) return null;
      if (communityData is List && communityData.isNotEmpty) {
        return Community.fromJson(communityData[0] as Map<String, dynamic>);
      } else if (communityData is Map<String, dynamic>) {
        return Community.fromJson(communityData);
      }
      return null;
    }

    return CommunityPost(
      id: json['id'].toString(),
      communityId: json['community_id'].toString(),
      authorId: json['author_id'].toString(),
      content: json['content'].toString(),
      imageUrl: json['image_url']?.toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
      isPinned: json['is_pinned'] as bool? ?? false,
      isEdited: json['is_edited'] as bool? ?? false,
      deletedAt: json['deleted_at'] != null 
          ? DateTime.parse(json['deleted_at'].toString())
          : null,
      likesCount: (json['likes_count'] as int?) ?? 0,
      commentsCount: (json['comments_count'] as int?) ?? 0,
      shareCount: (json['share_count'] as int?) ?? 0,
      viewCount: (json['view_count'] as int?) ?? 0,
      sharedFromPostId: json['shared_from_post_id']?.toString(),
      sharedFromCommunityId: json['shared_from_community_id']?.toString(),
      author: parseAuthor(json['profiles']),
      isLikedByUser: json['is_liked_by_user'] as bool?,
      isViewedByUser: json['is_viewed_by_user'] as bool?,
      community: parseCommunity(json['communities']),
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
      'deleted_at': deletedAt?.toIso8601String(),
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'share_count': shareCount,
      'view_count': viewCount,
      'shared_from_post_id': sharedFromPostId,
      'shared_from_community_id': sharedFromCommunityId,
      'profiles': author?.toJson(),
      'communities': community?.toJson(),
    };
  }

  CommunityPost copyWith({
    String? id,
    String? communityId,
    String? authorId,
    String? content,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    bool? isEdited,
    DateTime? deletedAt,
    int? likesCount,
    int? commentsCount,
    int? shareCount,
    int? viewCount,
    String? sharedFromPostId,
    String? sharedFromCommunityId,
    Profile? author,
    bool? isLikedByUser,
    bool? isViewedByUser,
    Community? community,
    List<CommunityComment>? comments,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      communityId: communityId ?? this.communityId,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      isEdited: isEdited ?? this.isEdited,
      deletedAt: deletedAt ?? this.deletedAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      shareCount: shareCount ?? this.shareCount,
      viewCount: viewCount ?? this.viewCount,
      sharedFromPostId: sharedFromPostId ?? this.sharedFromPostId,
      sharedFromCommunityId: sharedFromCommunityId ?? this.sharedFromCommunityId,
      author: author ?? this.author,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
      isViewedByUser: isViewedByUser ?? this.isViewedByUser,
      community: community ?? this.community,
      comments: comments ?? this.comments,
    );
  }

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get isShared => sharedFromPostId != null;
  bool get canEdit => true; // Add logic for edit permission

  @override
  String toString() {
    return 'CommunityPost{id: $id, content: ${content.length > 20 ? '${content.substring(0, 20)}...' : content}, likes: $likesCount, comments: $commentsCount}';
  }
}

class CommunityComment {
  final String id;
  final String postId;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? parentCommentId;
  final DateTime? deletedAt;
  final Profile? author;
  final List<CommunityComment>? replies;
  final int replyCount;
  final bool? isLikedByUser;
  final int likesCount;

  CommunityComment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.parentCommentId,
    this.deletedAt,
    this.author,
    this.replies,
    this.replyCount = 0,
    this.isLikedByUser,
    this.likesCount = 0,
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    // Handle author profiles
    Profile? parseAuthor(dynamic profilesData) {
      if (profilesData == null) return null;
      if (profilesData is List && profilesData.isNotEmpty) {
        return Profile.fromJson(profilesData[0] as Map<String, dynamic>);
      } else if (profilesData is Map<String, dynamic>) {
        return Profile.fromJson(profilesData);
      }
      return null;
    }

    return CommunityComment(
      id: json['id'].toString(),
      postId: json['post_id'].toString(),
      authorId: json['author_id'].toString(),
      content: json['content'].toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
      parentCommentId: json['parent_comment_id']?.toString(),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'].toString())
          : null,
      author: parseAuthor(json['profiles']),
      replyCount: (json['reply_count'] as int?) ?? 0,
      isLikedByUser: json['is_liked_by_user'] as bool?,
      likesCount: (json['likes_count'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'author_id': authorId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'parent_comment_id': parentCommentId,
      'deleted_at': deletedAt?.toIso8601String(),
      'profiles': author?.toJson(),
      'reply_count': replyCount,
      'likes_count': likesCount,
    };
  }

  CommunityComment copyWith({
    String? id,
    String? postId,
    String? authorId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? parentCommentId,
    DateTime? deletedAt,
    Profile? author,
    List<CommunityComment>? replies,
    int? replyCount,
    bool? isLikedByUser,
    int? likesCount,
  }) {
    return CommunityComment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      deletedAt: deletedAt ?? this.deletedAt,
      author: author ?? this.author,
      replies: replies ?? this.replies,
      replyCount: replyCount ?? this.replyCount,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
      likesCount: likesCount ?? this.likesCount,
    );
  }

  bool get isReply => parentCommentId != null;
  bool get hasReplies => replyCount > 0;

  @override
  String toString() {
    return 'CommunityComment{id: $id, content: ${content.length > 20 ? '${content.substring(0, 20)}...' : content}}';
  }
}

class CommunityPostShare {
  final String id;
  final String originalPostId;
  final String sharedPostId;
  final String sharedByUserId;
  final String? sharedToCommunityId;
  final DateTime createdAt;
  final CommunityPost? originalPost;
  final CommunityPost? sharedPost;

  CommunityPostShare({
    required this.id,
    required this.originalPostId,
    required this.sharedPostId,
    required this.sharedByUserId,
    this.sharedToCommunityId,
    required this.createdAt,
    this.originalPost,
    this.sharedPost,
  });

  factory CommunityPostShare.fromJson(Map<String, dynamic> json) {
    CommunityPost? parsePost(dynamic postData) {
      if (postData == null) return null;
      if (postData is List && postData.isNotEmpty) {
        return CommunityPost.fromJson(postData[0] as Map<String, dynamic>);
      } else if (postData is Map<String, dynamic>) {
        return CommunityPost.fromJson(postData);
      }
      return null;
    }

    return CommunityPostShare(
      id: json['id'].toString(),
      originalPostId: json['original_post_id'].toString(),
      sharedPostId: json['shared_post_id'].toString(),
      sharedByUserId: json['shared_by_user_id'].toString(),
      sharedToCommunityId: json['shared_to_community_id']?.toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
      originalPost: parsePost(json['original_post']),
      sharedPost: parsePost(json['shared_post']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'original_post_id': originalPostId,
      'shared_post_id': sharedPostId,
      'shared_by_user_id': sharedByUserId,
      'shared_to_community_id': sharedToCommunityId,
      'created_at': createdAt.toIso8601String(),
      'original_post': originalPost?.toJson(),
      'shared_post': sharedPost?.toJson(),
    };
  }
}

class CommunityStats {
  final String communityId;
  final int memberCount;
  final int postCount;
  final int todayActivityCount;
  final int totalLikes;
  final int totalComments;
  final int activeMembers;
  final DateTime lastActivity;

  CommunityStats({
    required this.communityId,
    required this.memberCount,
    required this.postCount,
    required this.todayActivityCount,
    required this.totalLikes,
    required this.totalComments,
    required this.activeMembers,
    required this.lastActivity,
  });

  factory CommunityStats.fromJson(Map<String, dynamic> json) {
    return CommunityStats(
      communityId: json['community_id'].toString(),
      memberCount: (json['member_count'] as int?) ?? 0,
      postCount: (json['post_count'] as int?) ?? 0,
      todayActivityCount: (json['today_activity_count'] as int?) ?? 0,
      totalLikes: (json['total_likes'] as int?) ?? 0,
      totalComments: (json['total_comments'] as int?) ?? 0,
      activeMembers: (json['active_members'] as int?) ?? 0,
      lastActivity: DateTime.parse(json['last_activity'].toString()),
    );
  }
}

class CommunityActivity {
  final String id;
  final String communityId;
  final String userId;
  final String activityType;
  final String? description;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final Community? community;
  final Profile? user;

  CommunityActivity({
    required this.id,
    required this.communityId,
    required this.userId,
    required this.activityType,
    this.description,
    this.metadata,
    required this.createdAt,
    this.community,
    this.user,
  });

  factory CommunityActivity.fromJson(Map<String, dynamic> json) {
    return CommunityActivity(
      id: json['id'].toString(),
      communityId: json['community_id'].toString(),
      userId: json['user_id'].toString(),
      activityType: json['activity_type'].toString(),
      description: json['description']?.toString(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'].toString()),
      community: json['communities'] != null
          ? Community.fromJson(json['communities'] as Map<String, dynamic>)
          : null,
      user: json['profiles'] != null
          ? Profile.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CreatePostRequest {
  final String communityId;
  final String content;
  final String? imageUrl;
  final String? imagePath;

  CreatePostRequest({
    required this.communityId,
    required this.content,
    this.imageUrl,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'community_id': communityId,
      'content': content,
      'image_url': imageUrl,
    };
  }
}

class CreateCommentRequest {
  final String postId;
  final String content;
  final String? parentCommentId;

  CreateCommentRequest({
    required this.postId,
    required this.content,
    this.parentCommentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'post_id': postId,
      'content': content,
      'parent_comment_id': parentCommentId,
    };
  }
}

class SharePostRequest {
  final String originalPostId;
  final String targetCommunityId;
  final String? additionalComment;

  SharePostRequest({
    required this.originalPostId,
    required this.targetCommunityId,
    this.additionalComment,
  });

  Map<String, dynamic> toJson() {
    return {
      'original_post_id': originalPostId,
      'target_community_id': targetCommunityId,
      'additional_comment': additionalComment,
    };
  }
}