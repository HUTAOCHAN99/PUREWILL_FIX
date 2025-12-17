import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:purewill/domain/model/community_model.dart';

class ProfileService {
  final SupabaseClient _supabase;

  ProfileService() : _supabase = Supabase.instance.client;

  // ============ PROFILE MANAGEMENT ============

  Future<Profile?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('user_id, full_name, avatar_url, level, current_xp')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        return Profile.fromJson(response);
      }

      return Profile(
        userId: userId,
        fullName: 'Pengguna',
        avatarUrl: null,
        level: 1,
        currentXp: 0,
      );
    } catch (e) {
      developer.log('❌ Error getting user profile: $e',
          name: 'ProfileService');
      return Profile(
        userId: userId,
        fullName: 'Pengguna',
        avatarUrl: null,
        level: 1,
        currentXp: 0,
      );
    }
  }

  Future<Map<String, Profile>> getProfiles(List<String> userIds) async {
    try {
      if (userIds.isEmpty) return {};

      final profilesResponse = await _supabase
          .from('profiles')
          .select('user_id, full_name, avatar_url, level, current_xp')
          .inFilter('user_id', userIds);

      final Map<String, Profile> profilesMap = {};
      for (var profile in profilesResponse) {
        final userIdStr = profile['user_id'].toString();
        profilesMap[userIdStr] = Profile.fromJson({
          'user_id': profile['user_id'],
          'full_name': profile['full_name'] ?? 'Pengguna',
          'avatar_url': profile['avatar_url'],
          'level': profile['level'],
          'current_xp': profile['current_xp'],
        });
      }

      return profilesMap;
    } catch (e) {
      developer.log('❌ Error fetching profiles: $e',
          name: 'ProfileService');
      return {};
    }
  }
}