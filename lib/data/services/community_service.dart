// lib\data\services\community_service.dart
import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:purewill/domain/model/community_model.dart';

class CommunityService {
  final SupabaseClient _supabase;

  CommunityService() : _supabase = Supabase.instance.client;

  // Get all communities with user's membership status
  Future<List<Community>> getCommunities(String userId) async {
    try {
      // Get all active communities
      final communitiesResponse = await _supabase
          .from('communities')
          .select('*')
          .eq('is_active', true)
          .order('member_count', ascending: false);

      // Get user's joined communities
      final userMemberships = await _supabase
          .from('community_members')
          .select('community_id')
          .eq('user_id', userId)
          .eq('is_banned', false);

      final joinedCommunityIds = (userMemberships as List<dynamic>)
          .map((item) => item['community_id'] as String)
          .toSet();

      return (communitiesResponse as List)
          .map((json) => Community.fromJson({
                ...json,
                'is_joined': joinedCommunityIds.contains(json['id']),
              }))
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
          .select('communities!inner(*)')
          .eq('user_id', userId)
          .eq('is_banned', false);

      return (response as List)
          .map((json) => Community.fromJson({
                ...json['communities'],
                'is_joined': true,
              }))
          .toList();
    } catch (e) {
      developer.log('Error fetching user communities: $e', name: 'CommunityService');
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
        return false; // Already a member
      }

      // Join community
      await _supabase.from('community_members').insert({
        'community_id': communityId,
        'user_id': userId,
        'joined_at': DateTime.now().toIso8601String(),
        'role': 'member',
      });

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
  Future<Community> getCommunityDetails(String communityId, String userId) async {
    try {
      final response = await _supabase
          .from('communities')
          .select('*')
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

      return Community.fromJson({
        ...response,
        'is_joined': isMember,
      });
    } catch (e) {
      developer.log('Error fetching community details: $e', name: 'CommunityService');
      rethrow;
    }
  }

  // Get community posts
  Future<List<CommunityPost>> getCommunityPosts(String communityId) async {
    try {
      // Get posts that are not deleted (deleted_at is null)
      final response = await _supabase
          .from('community_posts')
          .select('''
            *,
            profiles!community_posts_author_id_fkey(full_name, avatar_url)
          ''')
          .eq('community_id', communityId)
          .filter('deleted_at', 'is', null)
          .order('is_pinned', ascending: false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => CommunityPost.fromJson(json))
          .toList();
    } catch (e) {
      developer.log('Error fetching community posts: $e', name: 'CommunityService');
      rethrow;
    }
  }

  // Create a post
  Future<CommunityPost> createPost(
    String communityId,
    String userId,
    String content, {
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
            profiles!community_posts_author_id_fkey(full_name, avatar_url)
          ''')
          .single();

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

      return CommunityPost.fromJson(response);
    } catch (e) {
      developer.log('Error creating post: $e', name: 'CommunityService');
      rethrow;
    }
  }

  // Like/unlike a post
  Future<bool> toggleLikePost(String postId, String userId) async {
    try {
      // Check if already liked
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
        return false; // Now unliked
      } else {
        // Like
        await _supabase.from('community_likes').insert({
          'post_id': postId,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        });
        return true; // Now liked
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

  // Add comment to post
  Future<CommunityComment> addComment(
    String postId,
    String userId,
    String content, {
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
          .select('''
            *,
            profiles!community_comments_author_id_fkey(full_name, avatar_url)
          ''')
          .single();

      // Update comments count in post
      await _supabase
          .from('community_posts')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', postId);

      return CommunityComment.fromJson(response);
    } catch (e) {
      developer.log('Error adding comment: $e', name: 'CommunityService');
      rethrow;
    }
  }

  // Get post comments
  Future<List<CommunityComment>> getPostComments(String postId) async {
    try {
      final response = await _supabase
          .from('community_comments')
          .select('''
            *,
            profiles!community_comments_author_id_fkey(full_name, avatar_url)
          ''')
          .eq('post_id', postId)
          .filter('deleted_at', 'is', null)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => CommunityComment.fromJson(json))
          .toList();
    } catch (e) {
      developer.log('Error fetching comments: $e', name: 'CommunityService');
      rethrow;
    }
  }

  // Get trending communities (top 8 by member count)
  Future<List<Community>> getTrendingCommunities(String userId) async {
    try {
      final response = await _supabase
          .from('communities')
          .select('*')
          .eq('is_active', true)
          .order('member_count', ascending: false)
          .limit(8);

      // For each community, check if user is a member
      final communities = (response as List).map((json) async {
        final isMember = await _supabase
            .from('community_members')
            .select()
            .eq('community_id', json['id'])
            .eq('user_id', userId)
            .eq('is_banned', false)
            .maybeSingle()
            .then((result) => result != null);

        return Community.fromJson({
          ...json,
          'is_joined': isMember,
        });
      }).toList();

      return await Future.wait(communities);
    } catch (e) {
      developer.log('Error fetching trending communities: $e', name: 'CommunityService');
      return [];
    }
  }

  // Check if user is a member of specific community
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

      return {
        'member_count': membersResponse.length,
        'post_count': postsResponse.length,
        'today_activity_count': activitiesResponse.length,
      };
    } catch (e) {
      developer.log('Error getting community stats: $e', name: 'CommunityService');
      return {
        'member_count': 0,
        'post_count': 0,
        'today_activity_count': 0,
      };
    }
  }

  // Get user's recent activities in communities
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
      developer.log('Error fetching user activities: $e', name: 'CommunityService');
      return [];
    }
  }

  // Update user's last seen in community
  Future<void> updateLastSeen(String userId, String communityId) async {
    try {
      await _supabase
          .from('community_members')
          .update({
            'last_seen_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('community_id', communityId);
    } catch (e) {
      developer.log('Error updating last seen: $e', name: 'CommunityService');
    }
  }

  // Get unread posts count for user in community
  Future<int> getUnreadPostsCount(String userId, String communityId) async {
    try {
      // Get user's last seen time in this community
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
      
      // Count posts created after last seen
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