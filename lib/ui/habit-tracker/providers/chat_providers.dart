// lib/ui/habit-tracker/providers/chat_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:purewill/data/repository/user_repository.dart';
import 'package:purewill/data/services/chatbot/chatbot_service.dart';
import 'package:purewill/domain/model/profile_model.dart';
import 'package:purewill/domain/model/user_model.dart';
import 'package:purewill/ui/auth/auth_provider.dart';
import 'dart:developer';

// ============ AUTH & USER PROVIDERS ============

// Provider untuk mendapatkan user repository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiService = ref.watch(authApiServiceProvider);
  return UserRepository(apiService);
});

// Provider untuk mendapatkan current user dari AuthState
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.user;
});

// Provider untuk mendapatkan profile dari current user
final currentProfileProvider = FutureProvider<ProfileModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  
  final userRepository = ref.watch(userRepositoryProvider);
  try {
    final profile = await userRepository.fetchUserProfile(user.id);
    return profile;
  } catch (e, stackTrace) {
    log('Error fetching profile: $e', name: 'CHAT_PROVIDER');
    return null;
  }
});

// Provider untuk mendapatkan display name (full_name atau email)
final currentDisplayNameProvider = FutureProvider<String>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  final user = ref.watch(currentUserProvider);
  
  if (profile?.fullName != null && profile!.fullName!.isNotEmpty) {
    return profile.fullName!;
  }
  
  if (user?.fullName != null && user!.fullName!.isNotEmpty) {
    return user.fullName!;
  }
  
  if (user?.email != null && user!.email.isNotEmpty) {
    return user.email.split('@').first;
  }
  
  return 'Pengguna';
});

// ============ CHAT PROVIDERS ============

// Provider untuk ChatBotService - instance akan hidup selama app
final chatBotServiceProvider = Provider<ChatBotService>((ref) {
  return ChatBotService();
});

// Provider untuk menyimpan nama user di seluruh app
final chatUserNameProvider = StateProvider<String?>((ref) => null);

// Provider untuk tracking apakah chat sudah diinisialisasi
final chatInitializedProvider = StateProvider<bool>((ref) => false);