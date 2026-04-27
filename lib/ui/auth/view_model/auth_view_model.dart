// lib/ui/auth/view_model/auth_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:purewill/data/repository/auth_repository.dart';
import 'package:purewill/data/services/auth/biometric_service.dart';
import 'package:purewill/data/repository/secure_storage_repository.dart';
import 'package:purewill/domain/model/auth_model.dart';
import 'package:purewill/domain/model/user_model.dart';

enum AuthStatus { initial, success, loading, failure }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final UserModel? user;

  AuthState({this.status = AuthStatus.initial, this.errorMessage, this.user});

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    UserModel? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  final BiometricService _biometricService = BiometricService();
  final SecureStorageRepository _secureStorage = SecureStorageRepository();

  AuthViewModel(this._repository) : super(AuthState());

  Future<void> restoreSession() async {
    try {
      final restoredUser = await _repository.restoreSession();
      if (restoredUser == null) {
        return;
      }

      state = state.copyWith(
        status: AuthStatus.success,
        errorMessage: null,
        user: restoredUser,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.initial,
        errorMessage: null,
        user: null,
      );
    }
  }

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
      final user = await _repository.login(email: email, password: password);
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.success,
          errorMessage: null,
          user: user,
        );
      }
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.message,
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: "Login failed",
      );
      rethrow;
    }
  }

  /// ✅ UPDATE: Signup dengan parameter yang sesuai dengan AuthRepository
  Future<void> signup({
    required String fullname,
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String gender,
    required DateTime birthDate,
  }) async {
    try {
      if (kDebugMode) {
        print('═══════════════════════════════════════════');
        print('🔐 [AUTH] SIGNUP STARTED');
        print('📝 Fullname: $fullname');
        print('📝 Username: $username');
        print('📧 Email: $email');
        print('⚥ Gender: $gender');
        print('📅 BirthDate: $birthDate');
        print('═══════════════════════════════════════════');
      }

      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

      // Panggil repository.signup dengan parameter yang benar
      final user = await _repository.signup(
        fullname: fullname,
        username: username,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        gender: gender,
        birthDate: birthDate,
      );

      if (user != null) {
        if (kDebugMode) print('✅ SIGNUP SUCCESS - User ID: ${user.id}');

        if (kDebugMode) print('✅ Default habits initialized');

        state = state.copyWith(
          status: AuthStatus.success,
          errorMessage: null,
          user: user,
        );
      } else {
        throw AuthException('Failed to create user account');
      }
    } on AuthException catch (e) {
      if (kDebugMode) print('❌ SIGNUP AUTH EXCEPTION: ${e.message}');
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.message,
      );
    } catch (e) {
      if (kDebugMode) print('❌ SIGNUP ERROR: $e');
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: "Signup failed: $e",
      );
    }
  }

  Future<void> logout() async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
      await _repository.logout();
      await clearSavedCredentials();

      state = AuthState(
        status: AuthStatus.initial,
        user: null,
        errorMessage: null,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: "Logout failed",
      );
    }
  }

  // ============ BIOMETRIC METHODS ============

  Future<bool> loginWithBiometric() async {
    try {
      final isAvailable = await _biometricService.isBiometricAvailable();
      if (!isAvailable) {
        state = state.copyWith(
          status: AuthStatus.failure,
          errorMessage:
              'Biometric authentication is not available on this device',
        );
        return false;
      }

      final savedCredentials = await _secureStorage.getSavedCredentials();
      if (savedCredentials == null) {
        state = state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'No saved login found. Please login first.',
        );
        return false;
      }

      final result = await _biometricService.authenticate(
        reason: 'Authenticate to login to PureWill',
        title: 'Login with Fingerprint',
        subtitle: 'Place your finger on the sensor to continue',
        cancelButtonText: 'Use Password Instead',
      );

      if (!result.success) {
        state = state.copyWith(
          status: AuthStatus.failure,
          errorMessage:
              result.errorMessage ?? 'Biometric authentication failed',
        );
        return false;
      }

      state = state.copyWith(status: AuthStatus.loading);

      final user = await _repository.login(
        email: savedCredentials.email,
        password: savedCredentials.password,
      );

      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.success,
          errorMessage: null,
          user: user,
        );
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Failed to login with saved credentials',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Biometric login failed: $e',
      );
      return false;
    }
  }

  Future<bool> isBiometricLoginAvailable() async {
    final isAvailable = await _biometricService.isBiometricAvailable();
    final isEnabled = await _secureStorage.isBiometricEnabled();
    return isAvailable && isEnabled;
  }

  Future<void> saveCredentialsForBiometric({
    required String email,
    required String password,
    required bool enableBiometric,
  }) async {
    await _secureStorage.saveCredentials(
      email: email,
      password: password,
      enableBiometric: enableBiometric,
    );
  }

  Future<void> clearSavedCredentials() async {
    await _secureStorage.clearCredentials();
  }
}
