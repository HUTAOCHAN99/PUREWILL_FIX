// lib/data/repository/user_repository.dart

import 'dart:developer';
import 'package:purewill/data/services/auth/auth_api_service.dart';
import 'package:purewill/domain/model/profile_model.dart';

class UserRepository {
  final AuthApiService _authApiService;
  
  UserRepository(this._authApiService);

  Future<void> createUserProfile({
    required String userId,
    required String fullName,
  }) async {
    try {
      // Profile sudah dibuat saat registrasi di backend
      log('User profile will be created by backend for user: $userId');
    } catch (e, stackTrace) {
      log('Failed to create user profile', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<ProfileModel?> fetchUserProfile(String userId) async {
    try {
      final response = await _authApiService.getUserProfile(userId);
      
      return ProfileModel(
        id: response['data']['id'].toString(),
        userId: response['data']['id'].toString(),
        email: response['data']['email'],
        fullName: response['data']['fullname'] ?? response['data']['username'],
        avatarUrl: response['data']['avatarUrl'],
        level: response['data']['level'] ?? 1,
        currentXP: response['data']['currentXp'] ?? 0,
        xpToNextLevel: 100,
        isPremiumUser: response['data']['isPremium'] ?? false,
        currentPlanId: null,
        currentPlanName: null,
        subscriptionStatus: null,
      );
    } catch (e, stackTrace) {
      log('Failed to fetch user profile', error: e, stackTrace: stackTrace);
      return null;
    }
  }

}