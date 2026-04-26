// lib/data/repository/auth_repository.dart
import 'dart:developer';

import 'package:purewill/data/services/auth/auth_api_service.dart';
import 'package:purewill/domain/model/auth_model.dart';
import 'package:purewill/domain/model/user_model.dart';

class AuthRepository {
  final AuthApiService _authApiService;
  String? _accessToken;

  AuthRepository(this._authApiService);

  String? get accessToken => _accessToken;

  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _authApiService.login(email, password);

      _accessToken = response['accessToken'];

      return UserModel(
        id: 'temp',
        email: email,
        fullName: email.split('@').first,
        avatarUrl: null,
      );
    } on AuthException catch (e, stackTrace) {
      log('AUTH FAILURE: Login failed.', error: e, stackTrace: stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      log(
        'GENERAL FAILURE: Unexpected error during login.',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<UserModel?> signup({
    required String fullname,
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String gender,
    required DateTime birthDate,
  }) async {
    try {
      final request = RegisterRequest(
        email: email,
        username: username,
        fullname: fullname,
        gender: gender.toUpperCase(),
        birthDate: birthDate,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      final response = await _authApiService.register(request);

      if (response['data'] != null) {
        final userData = response['data'];
        return UserModel(
          id: userData['id'].toString(),
          email: userData['email'],
          fullName: userData['username'],
          avatarUrl: null,
        );
      }

      return null;
    } on AuthException catch (e, stackTrace) {
      log(
        'AUTH FAILURE: Signup failed: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      log(
        'GENERAL FAILURE: Unexpected error during signup: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authApiService.logout();
      _accessToken = null;
    } on AuthException catch (e, stackTrace) {
      log('AUTH FAILURE: Logout failed.', error: e, stackTrace: stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      log(
        'GENERAL FAILURE: Unexpected error during logout.',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
