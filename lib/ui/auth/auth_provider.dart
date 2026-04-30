// lib/ui/auth/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:purewill/data/repository/auth_repository.dart';
import 'package:purewill/data/repository/user_repository.dart';
import 'package:purewill/data/repository/secure_storage_repository.dart';
import 'package:purewill/data/services/auth/auth_api_service.dart';
import 'package:purewill/data/services/auth/auth_service.dart';
import 'package:purewill/ui/auth/view_model/auth_view_model.dart';

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthRepository(authService, SecureStorageRepository());
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiService = ref.watch(authApiServiceProvider);
  return UserRepository(apiService);
});

final authNotifierProvider = StateNotifierProvider<AuthViewModel, AuthState>((
  ref,
) {
  final repository = ref.watch(authRepositoryProvider);
  final viewModel = AuthViewModel(repository);
  Future.microtask(() => viewModel.restoreSession(requireBiometric: true));
  return viewModel;
});
