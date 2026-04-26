// lib/ui/auth/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:purewill/data/repository/auth_repository.dart';
import 'package:purewill/data/repository/user_repository.dart';
import 'package:purewill/data/services/auth/auth_api_service.dart';
import 'package:purewill/ui/auth/view_model/auth_view_model.dart';
import 'package:purewill/ui/habit-tracker/habit_provider.dart';

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ref.watch(authApiServiceProvider);
  return AuthRepository(apiService);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiService = ref.watch(authApiServiceProvider);
  return UserRepository(apiService);
});

final authNotifierProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final habitRepository = ref.watch(habitRepositoryProvider);
  final habitSessionRepository = ref.watch(habitSessionRepositoryProvider);
  return AuthViewModel(
    repository,
    userRepository,
    habitRepository,
    habitSessionRepository,
  );
});