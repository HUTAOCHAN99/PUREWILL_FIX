import 'dart:developer' as developer;
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purewill/domain/model/community_model.dart';

class CommunityService {
  final SupabaseClient _supabase;
  final String _bucketName = 'community-posts';
  final ImagePicker _imagePicker = ImagePicker();

  CommunityService() : _supabase = Supabase.instance.client;

  // ============ COMMUNITY MANAGEMENT ============

  // Get all communities with user's membership status
  Future<List<Community>> getCommunities(String userId) async {
    try {
      final communitiesResponse = await _supabase
          .from('communities')
          .select('''
            *,
            categories (id, name, created_at)
          ''')
          .eq('is_active', true)
          .order('member_count', ascending: false);

      final userMemberships = await _supabase
          .from('community_members')
          .select('community_id')
          .eq('user_id', userId)
          .eq('is_banned', false);

      final joinedCommunityIds = (userMemberships as List<dynamic>)
          .map((item) => item['community_id'] as String)
          .toSet();

      return (communitiesResponse as List)
          .map(
            (json) => Community.fromJson({
              ...json,
              'is_joined': joinedCommunityIds.contains(json['id']),
            }),
          )
          .toList();
    } catch (e) {
      developer.log('Error fetching communities: $e', name: 'CommunityService');
      rethrow;
    }
  }

  // Get user's joined communities
  Future<List<Community>> getUserCommunities(String userId) async {
    try {
      final response = await _supabase
          .from('community_members')
          .select('''
            communities!inner(*, categories (id, name, created_at))
          ''')
          .eq('user_id', userId)
          .eq('is_banned', false);

      return (response as List)
          .map(
            (json) =>
                Community.fromJson({...json['communities'], 'is_joined': true}),
          )
          .toList();
    } catch (e) {
      developer.log(
        'Error fetching user communities: $e',
        name: 'CommunityService',
      );
      rethrow;
    }
  }

  // Join a community
  Future<bool> joinCommunity(String communityId, String userId) async {
    try {
      // Check if already a member
      final existingMember = await _supabase
          .from('community_members')
          .select()
          .eq('community_id', communityId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingMember != null) {
        return false;
      }

      await _supabase.from('community_members').insert({
        'community_id': communityId,
        'user_id': userId,
        'joined_at': DateTime.now().toIso8601String(),
        'role': 'member',
      });

      // Update member count
      await _supabase.rpc(
        'increment_member_count',
        params: {'community_id': communityId},
      );

      // Log activity
      await _supabase.from('community_activities').insert({
        'community_id': communityId,
        'user_id': userId,
        'activity_type': 'join',
        'description': 'User joined the community',
        'metadata': {'community_id': communityId},
      });

      return true;
    } catch (e) {
      developer.log('Error joining community: $e', name: 'CommunityService');
      rethrow;
    }
  }

  // Leave a community
  Future<bool> leaveCommunity(String communityId, String userId) async {
    try {
      await _supabase
          .from('community_members')
          .delete()
          .eq('community_id', communityId)
          .eq('user_id', userId);

      // Update member count
      await _supabase.rpc(
        'decrement_member_count',
        params: {'community_id': communityId},
      );

      // Log activity
      await _supabase.from('community_activities').insert({
        'community_id': communityId,
        'user_id': userId,
        'activity_type': 'leave',
        'description': 'User left the community',
        'metadata': {'community_id': communityId},
      });

      return true;
    } catch (e) {
      developer.log('Error leaving community: $e', name: 'CommunityService');
      rethrow;
    }
  }

  // Get community details
  Future<Community> getCommunityDetails(
    String communityId,
    String userId,
  ) async {
    try {
      final response = await _supabase
          .from('communities')
          .select('''
            *,
            categories (id, name, created_at)
          ''')
          .eq('id', communityId)
          .single();

      // Check if user is a member
      final isMember = await _supabase
          .from('community_members')
          .select()
          .eq('community_id', communityId)
          .eq('user_id', userId)
          .eq('is_banned', false)
          .maybeSingle()
          .then((result) => result != null);

      return Community.fromJson({...response, 'is_joined': isMember});
    } catch (e) {
      developer.log(
        'Error fetching community details: $e',
        name: 'CommunityService',
      );
      rethrow;
    }
  }

  // ============ POST MANAGEMENT ============

  // Get community posts with realtime stream
  Stream<List<CommunityPost>> streamCommunityPosts(
    String communityId,
    String userId,
  ) {
    return _supabase
        .from('community_posts')
        .stream(primaryKey: ['id'])
        .eq('community_id', communityId)
        .order('is_pinned', ascending: false)
        .order('created_at', ascending: false)
        .asyncMap((posts) async {
          // Filter di client side untuk menghapus post yang dihapus
          final filteredPosts = (posts as List)
              .where((post) => post['deleted_at'] == null)
              .toList();

          return await Future.wait(
            filteredPosts.map((post) async {
              final isLiked = await isPostLikedByUser(post['id'], userId);
              final isViewed = await isPostViewedByUser(post['id'], userId);

              return CommunityPost.fromJson({
                ...post,
                'is_liked_by_user': isLiked,
                'is_viewed_by_user': isViewed,
              });
            }).toList(),
          );
        });
  }

  Future<List<CommunityPost>> getCommunityPosts(
    String communityId, {
    String? userId,
  }) async {
    try {
      // 1. Ambil posts dulu
      final postsResponse = await _supabase
          .from('community_posts')
          .select('''
          *,
          communities!community_posts_community_id_fkey(name, icon_name, color)
        ''')
          .eq('community_id', communityId)
          .filter('deleted_at', 'is', null)
          .order('is_pinned', ascending: false)
          .order('created_at', ascending: false);

      final posts = (postsResponse as List)
          .map((json) => CommunityPost.fromJson(json))
          .toList();

      // 2. Ambil author profiles secara terpisah
      final authorIds = posts.map((post) => post.authorId).toSet().toList();

      if (authorIds.isNotEmpty) {
        final profilesResponse = await _supabase
            .from('profiles')
            .select('user_id, full_name, avatar_url')
            .inFilter('user_id', authorIds);

        final profilesMap = {
          for (var profile in profilesResponse as List<dynamic>)
            profile['user_id'].toString(): profile,
        };

        // 3. Gabungkan data
        final combinedPosts = posts.map((post) {
          final authorProfile = profilesMap[post.authorId];
          return post.copyWith(
            author: authorProfile != null
                ? Profile.fromJson({
                    'user_id': authorProfile['user_id'],
                    'full_name': authorProfile['full_name'],
                    'avatar_url': authorProfile['avatar_url'],
                  })
                : null,
            isLikedByUser: userId != null
                ? null // Akan diisi nanti
                : null,
            isViewedByUser: userId != null
                ? null // Akan diisi nanti
                : null,
          );
        }).toList();

        // 4. Jika ada userId, cek like dan view status
        if (userId != null) {
          return await Future.wait(
            combinedPosts.map((post) async {
              final isLiked = await isPostLikedByUser(post.id, userId);
              final isViewed = await isPostViewedByUser(post.id, userId);
              return post.copyWith(
                isLikedByUser: isLiked,
                isViewedByUser: isViewed,
              );
            }).toList(),
          );
        }

        return combinedPosts;
      }

      return posts;
    } catch (e) {
      developer.log(
        'Error fetching community posts: $e',
        name: 'CommunityService',
      );
      rethrow;
    }
  }

  // Upload image to Supabase Storage
  Future<String?> uploadImage(File imageFile, String userId) async {
    try {
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'posts/$fileName';

      // Compress image if needed
      final compressedFile = await _compressImage(imageFile);

      await _supabase.storage
          .from(_bucketName)
          .upload(
            filePath,
            compressedFile,
            fileOptions: FileOptions(upsert: true, contentType: 'image/jpeg'),
          );

      final imageUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      developer.log('Error uploading image: $e', name: 'CommunityService');
      return null;
    }
  }

  Future<File> _compressImage(File imageFile) async {
    // Implement image compression here
    // You can use flutter_image_compress package
    return imageFile;
  }

  // Pick image from gallery
  Future<XFile?> pickImage() async {
    try {
      return await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
    } catch (e) {
      developer.log('Error picking image: $e', name: 'CommunityService');
      return null;
    }
  }

  // Create post with image
  Future<CommunityPost> createPostWithImage({
    required String communityId,
    required String userId,
    required String content,
    XFile? imageFile,
  }) async {
    try {
      String? imageUrl;

      if (imageFile != null) {
        final file = File(imageFile.path);
        imageUrl = await uploadImage(file, userId);
      }

      return await createPost(
        communityId: communityId,
        userId: userId,
        content: content,
        imageUrl: imageUrl,
      );
    } catch (e) {
      developer.log(
        'Error creating post with image: $e',
        name: 'CommunityService',
      );
      rethrow;
    }
  }

  // Create a post
  Future<CommunityPost> createPost({
    required String communityId,
    required String userId,
    required String content,
    String? imageUrl,
  }) async {
    try {
      final response = await _supabase
          .from('community_posts')
          .insert({
            'community_id': communityId,
            'author_id': userId,
            'content': content,
            'image_url': imageUrl,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select('''
          *,
          communities!community_posts_community_id_fkey(name, icon_name, color)
        ''')
          .single();

      // Ambil profile author terpisah
      final profileResponse = await _supabase
          .from('profiles')
          .select('user_id, full_name, avatar_url')
          .eq('user_id', userId)
          .maybeSingle();

      final postData = Map<String, dynamic>.from(response);
      if (profileResponse != null) {
        postData['profiles'] = profileResponse;
      }

      // Log activity
      await _supabase.from('community_activities').insert({
        'community_id': communityId,
        'user_id': userId,
        'activity_type': 'post',
        'description': 'User created a new post',
        'metadata': {
          'post_id': response['id'],
          'content_preview': content.length > 50
              ? '${content.substring(0, 50)}...'
              : content,
        },
      });

      return CommunityPost.fromJson(postData);
    } catch (e) {
      developer.log('Error creating post: $e', name: 'CommunityService');
      rethrow;
    }
  }

  // Update post
  Future<CommunityPost> updatePost({
    required String postId,
    required String content,
    String? imageUrl,
  }) async {
    try {
      final response = await _supabase
          .from('community_posts')
          .update({
            'content': content,
            'image_url': imageUrl,
            'updated_at': DateTime.now().toIso8601String(),
            'is_edited': true,
          })
          .eq('id', postId)
          .select('''
            *,
            profiles(user_id, full_name, avatar_url)
          ''')
          .single();

      return CommunityPost.fromJson(response);
    } catch (e) {
      developer.log('Error updating post: $e', name: 'CommunityService');
      rethrow;
    }
  }

  // Delete post (soft delete)
  Future<bool> deletePost(String postId) async {
    try {
      await _supabase
          .from('community_posts')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', postId);

      return true;
    } catch (e) {
      developer.log('Error deleting post: $e', name: 'CommunityService');
      return false;
    }
  }

  // ============ LIKES ============

  // Like/unlike a post
  Future<bool> toggleLikePost(String postId, String userId) async {
    try {
      final existingLike = await _supabase
          .from('community_likes')
          .select()
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingLike != null) {
        // Unlike
        await _supabase
            .from('community_likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', userId);

        // Decrement likes count
        await _supabase.rpc(
          'decrement_post_likes',
          params: {'post_id': postId},
        );

        return false;
      } else {
        // Like
        await _supabase.from('community_likes').insert({
          'post_id': postId,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        });

        // Increment likes count
        await _supabase.rpc(
          'increment_post_likes',
          params: {'post_id': postId},
        );

        return true;
      }
    } catch (e) {
      developer.log('Error toggling like: $e', name: 'CommunityService');
      rethrow;
    }
  }

  // Get post likes count
  Future<int> getPostLikesCount(String postId) async {
    try {
      final response = await _supabase
          .from('community_likes')
          .select()
          .eq('post_id', postId);

      return response.length;
    } catch (e) {
      developer.log('Error getting likes count: $e', name: 'CommunityService');
      return 0;
    }
  }

  // Check if user liked a post
  Future<bool> isPostLikedByUser(String postId, String userId) async {
    try {
      final existingLike = await _supabase
          .from('community_likes')
          .select()
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();

      return existingLike != null;
    } catch (e) {
      developer.log('Error checking like status: $e', name: 'CommunityService');
      return false;
    }
  }

  // ============ COMMENTS ============

  // Add comment to post
  Future<CommunityComment> addComment({
    required String postId,
    required String userId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final response = await _supabase
          .from('community_comments')
          .insert({
            'post_id': postId,
            'author_id': userId,
            'content': content,
            'parent_comment_id': parentCommentId,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select('*')
          .single();

      // Ambil profile author terpisah
      final profileResponse = await _supabase
          .from('profiles')
          .select('user_id, full_name, avatar_url')
          .eq('user_id', userId)
          .maybeSingle();

      final commentData = Map<String, dynamic>.from(response);
      if (profileResponse != null) {
        commentData['profiles'] = profileResponse;
      }

      // Update comments count in post
      await _supabase.rpc(
        'increment_post_comments',
        params: {'post_id': postId},
      );

      return CommunityComment.fromJson(commentData);
    } catch (e) {
      developer.log('Error adding comment: $e', name: 'CommunityService');
      rethrow;
    }
  }

  // Get post comments with replies
  Future<List<CommunityComment>> getPostComments(
    String postId, {
    String? userId,
  }) async {
    try {
      final response = await _supabase
          .from('community_comments')
          .select('''
            *,
            profiles(user_id, full_name, avatar_url)
          ''')
          .eq('post_id', postId)
          .filter('deleted_at', 'is', null)
          .order('created_at', ascending: true);

      final comments = (response as List)
          .map((json) => CommunityComment.fromJson(json))
          .toList();

      // Group comments by parent
      final Map<String, List<CommunityComment>> repliesMap = {};
      final List<CommunityComment> topLevelComments = [];

      for (var comment in comments) {
        if (comment.parentCommentId != null) {
          repliesMap
              .putIfAbsent(comment.parentCommentId!, () => [])
              .add(comment);
        } else {
          topLevelComments.add(comment);
        }
      }

      // Attach replies to parent comments
      final List<CommunityComment> finalComments = [];
      for (var comment in topLevelComments) {
        final replies = repliesMap[comment.id] ?? [];
        if (replies.isNotEmpty) {
          finalComments.add(comment.copyWith(replies: replies));
        } else {
          finalComments.add(comment);
        }
      }

      // If userId provided, check like status
      if (userId != null) {
        return await Future.wait(
          finalComments.map((comment) async {
            final isLiked = await isCommentLikedByUser(comment.id, userId);
            return comment.copyWith(isLikedByUser: isLiked);
          }).toList(),
        );
      }

      return finalComments;
    } catch (e) {
      developer.log('Error fetching comments: $e', name: 'CommunityService');
      rethrow;
    }
  }

  // Like/unlike comment
  Future<bool> toggleLikeComment(String commentId, String userId) async {
    try {
      final existingLike = await _supabase
          .from('community_comment_likes')
          .select()
          .eq('comment_id', commentId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingLike != null) {
        // Unlike
        await _supabase
            .from('community_comment_likes')
            .delete()
            .eq('comment_id', commentId)
            .eq('user_id', userId);
        return false;
      } else {
        // Like
        await _supabase.from('community_comment_likes').insert({
          'comment_id': commentId,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        });
        return true;
      }
    } catch (e) {
      developer.log(
        'Error toggling comment like: $e',
        name: 'CommunityService',
      );
      return false;
    }
  }

  Future<bool> isCommentLikedByUser(String commentId, String userId) async {
    try {
      final existingLike = await _supabase
          .from('community_comment_likes')
          .select()
          .eq('comment_id', commentId)
          .eq('user_id', userId)
          .maybeSingle();
      return existingLike != null;
    } catch (e) {
      return false;
    }
  }

  // ============ SHARING ============

  // Share post to another community
  Future<CommunityPost> sharePostToCommunity({
    required String originalPostId,
    required String targetCommunityId,
    required String userId,
    String? additionalComment,
  }) async {
    try {
      // Get original post
      final originalPost = await _supabase
          .from('community_posts')
          .select('''
            *,
            profiles(user_id, full_name, avatar_url)
          ''')
          .eq('id', originalPostId)
          .single();

      // Create new post in target community
      final newPost = await createPost(
        communityId: targetCommunityId,
        userId: userId,
        content: additionalComment ?? 'Shared from another community',
        imageUrl: originalPost['image_url'],
      );

      // Update shared_from fields
      await _supabase
          .from('community_posts')
          .update({
            'shared_from_post_id': originalPostId,
            'shared_from_community_id': originalPost['community_id'],
          })
          .eq('id', newPost.id);

      // Increment share count
      await _supabase.rpc(
        'increment_post_shares',
        params: {'post_id': originalPostId},
      );

      // Record share activity
      await _supabase.from('community_post_shares').insert({
        'original_post_id': originalPostId,
        'shared_post_id': newPost.id,
        'shared_by_user_id': userId,
        'shared_to_community_id': targetCommunityId,
      });

      return newPost.copyWith(
        sharedFromPostId: originalPostId,
        sharedFromCommunityId: originalPost['community_id'],
      );
    } catch (e) {
      developer.log('Error sharing post: $e', name: 'CommunityService');
      rethrow;
    }
  }

  // Get post shares
  Future<List<CommunityPostShare>> getPostShares(String postId) async {
    try {
      final response = await _supabase
          .from('community_post_shares')
          .select('''
            *,
            original_post!original_post_id(*, profiles(user_id, full_name, avatar_url)),
            shared_post!shared_post_id(*, profiles(user_id, full_name, avatar_url), communities(name))
          ''')
          .eq('original_post_id', postId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => CommunityPostShare.fromJson(json))
          .toList();
    } catch (e) {
      developer.log('Error getting post shares: $e', name: 'CommunityService');
      return [];
    }
  }

  // ============ VIEWS ============

  // Track post view
  Future<void> trackPostView(String postId, String userId) async {
    try {
      final existingView = await _supabase
          .from('community_post_views')
          .select()
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingView == null) {
        await _supabase.from('community_post_views').insert({
          'post_id': postId,
          'user_id': userId,
        });

        await _supabase.rpc(
          'increment_post_views',
          params: {'post_id': postId},
        );
      }
    } catch (e) {
      developer.log('Error tracking post view: $e', name: 'CommunityService');
    }
  }

  Future<bool> isPostViewedByUser(String postId, String userId) async {
    try {
      final view = await _supabase
          .from('community_post_views')
          .select()
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();
      return view != null;
    } catch (e) {
      return false;
    }
  }

  // ============ SEARCH ============

  // Search posts
  Future<List<CommunityPost>> searchPosts({
    required String query,
    String? communityId,
    int limit = 20,
  }) async {
    try {
      var queryBuilder = _supabase
          .from('community_posts')
          .select('''
            *,
            profiles(user_id, full_name, avatar_url),
            communities(name, icon_name)
          ''')
          .filter('deleted_at', 'is', null)
          .textSearch('content', query);

      if (communityId != null) {
        queryBuilder = queryBuilder.eq('community_id', communityId);
      }

      final response = await queryBuilder
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => CommunityPost.fromJson(json))
          .toList();
    } catch (e) {
      developer.log('Error searching posts: $e', name: 'CommunityService');
      return [];
    }
  }

  // Search communities
  Future<List<Community>> searchCommunities(String query) async {
    try {
      final response = await _supabase
          .from('communities')
          .select('''
            *,
            categories (id, name, created_at)
          ''')
          .ilike('name', '%$query%')
          .eq('is_active', true)
          .order('member_count', ascending: false)
          .limit(20);

      return (response as List)
          .map((json) => Community.fromJson(json))
          .toList();
    } catch (e) {
      developer.log(
        'Error searching communities: $e',
        name: 'CommunityService',
      );
      return [];
    }
  }

  // ============ STATISTICS ============

  // Get community statistics
  Future<Map<String, dynamic>> getCommunityStats(String communityId) async {
    try {
      // Get member count
      final membersResponse = await _supabase
          .from('community_members')
          .select()
          .eq('community_id', communityId)
          .eq('is_banned', false);

      // Get posts count
      final postsResponse = await _supabase
          .from('community_posts')
          .select()
          .eq('community_id', communityId)
          .filter('deleted_at', 'is', null);

      // Get today's activity count
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final activitiesResponse = await _supabase
          .from('community_activities')
          .select()
          .eq('community_id', communityId)
          .gte('created_at', startOfDay.toIso8601String());

      // Get total likes and comments
      final posts = await _supabase
          .from('community_posts')
          .select('likes_count, comments_count')
          .eq('community_id', communityId)
          .filter('deleted_at', 'is', null);

      int totalLikes = 0;
      int totalComments = 0;

      for (var post in posts) {
        totalLikes += (post['likes_count'] as int?) ?? 0;
        totalComments += (post['comments_count'] as int?) ?? 0;
      }

      return {
        'member_count': membersResponse.length,
        'post_count': postsResponse.length,
        'today_activity_count': activitiesResponse.length,
        'total_likes': totalLikes,
        'total_comments': totalComments,
        'active_members': membersResponse.length, // Simple active count
        'last_activity': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      developer.log(
        'Error getting community stats: $e',
        name: 'CommunityService',
      );
      return {
        'member_count': 0,
        'post_count': 0,
        'today_activity_count': 0,
        'total_likes': 0,
        'total_comments': 0,
        'active_members': 0,
        'last_activity': DateTime.now().toIso8601String(),
      };
    }
  }

  // Get user's posts
  Future<List<CommunityPost>> getUserPosts(String userId) async {
    try {
      final response = await _supabase
          .from('community_posts')
          .select('''
            *,
            profiles(user_id, full_name, avatar_url),
            communities(name, icon_name)
          ''')
          .eq('author_id', userId)
          .filter('deleted_at', 'is', null)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => CommunityPost.fromJson(json))
          .toList();
    } catch (e) {
      developer.log('Error fetching user posts: $e', name: 'CommunityService');
      return [];
    }
  }

  // Get trending communities
  Future<List<Community>> getTrendingCommunities(String userId) async {
    try {
      final response = await _supabase
          .from('communities')
          .select('''
            *,
            categories (id, name, created_at)
          ''')
          .eq('is_active', true)
          .order('member_count', ascending: false)
          .limit(8);

      final communities = (response as List).map((json) async {
        final isMember = await _supabase
            .from('community_members')
            .select()
            .eq('community_id', json['id'])
            .eq('user_id', userId)
            .eq('is_banned', false)
            .maybeSingle()
            .then((result) => result != null);

        return Community.fromJson({...json, 'is_joined': isMember});
      }).toList();

      return await Future.wait(communities);
    } catch (e) {
      developer.log(
        'Error fetching trending communities: $e',
        name: 'CommunityService',
      );
      return [];
    }
  }

  // Check if user is a member
  Future<bool> isCommunityMember(String userId, String communityId) async {
    try {
      final membership = await _supabase
          .from('community_members')
          .select()
          .eq('user_id', userId)
          .eq('community_id', communityId)
          .eq('is_banned', false)
          .maybeSingle();

      return membership != null;
    } catch (e) {
      developer.log('Error checking membership: $e', name: 'CommunityService');
      return false;
    }
  }

  // Get user's recent activities
  Future<List<Map<String, dynamic>>> getUserCommunityActivities(
    String userId,
    int limit,
  ) async {
    try {
      final response = await _supabase
          .from('community_activities')
          .select('''
            *,
            communities!community_activities_community_id_fkey(name, icon_name, color)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (e) {
      developer.log(
        'Error fetching user activities: $e',
        name: 'CommunityService',
      );
      return [];
    }
  }

  // Update last seen
  Future<void> updateLastSeen(String userId, String communityId) async {
    try {
      await _supabase
          .from('community_members')
          .update({'last_seen_at': DateTime.now().toIso8601String()})
          .eq('user_id', userId)
          .eq('community_id', communityId);
    } catch (e) {
      developer.log('Error updating last seen: $e', name: 'CommunityService');
    }
  }

  // Get unread posts count
  Future<int> getUnreadPostsCount(String userId, String communityId) async {
    try {
      final membership = await _supabase
          .from('community_members')
          .select('last_seen_at')
          .eq('user_id', userId)
          .eq('community_id', communityId)
          .maybeSingle();

      if (membership == null || membership['last_seen_at'] == null) {
        return 0;
      }

      final lastSeen = DateTime.parse(membership['last_seen_at'] as String);

      final response = await _supabase
          .from('community_posts')
          .select()
          .eq('community_id', communityId)
          .filter('deleted_at', 'is', null)
          .gte('created_at', lastSeen.toIso8601String());

      return response.length;
    } catch (e) {
      developer.log('Error getting unread posts: $e', name: 'CommunityService');
      return 0;
    }
  }
}
