import 'dart:developer';

import 'package:purewill/data/repository/secure_storage_repository.dart';
import 'package:purewill/data/services/auth/auth_service.dart';
import 'package:purewill/domain/model/auth_model.dart';
import 'package:purewill/domain/model/user_model.dart';

class AuthRepository {
  final AuthService _authService;
  final SecureStorageRepository _secureStorageRepository;
  String? _accessToken;

  AuthRepository(
    this._authService, [
    SecureStorageRepository? secureStorageRepository,
  ]) : _secureStorageRepository =
           secureStorageRepository ?? SecureStorageRepository();

  String? get accessToken => _accessToken;

  Future<String?> getStoredAccessToken() async {
    return _secureStorageRepository.getAccessToken();
  }

  Future<void> restoreAccessToken() async {
    final storedToken = await _secureStorageRepository.getAccessToken();
    final storedRefreshCookie = await _secureStorageRepository
        .getRefreshTokenCookie();
    _accessToken = storedToken;
    if (storedToken != null) {
      _authService.setAccessToken(storedToken);
    }
    if (storedRefreshCookie != null) {
      _authService.setRefreshTokenCookie(storedRefreshCookie);
    }
  }

  Future<UserModel?> restoreSession() async {
    await restoreAccessToken();

    if (_accessToken != null) {
      try {
        final response = await _authService.checkSession();
        return _userFromSessionResponse(response);
      } on AuthException {
        await _secureStorageRepository.clearAccessToken();
        _accessToken = null;
      }
    }

    final storedRefreshCookie = await _secureStorageRepository
        .getRefreshTokenCookie();
    if (storedRefreshCookie == null) {
      return null;
    }

    try {
      final refreshed = await _authService.refreshSession();
      _accessToken = refreshed['accessToken'] as String?;
      if (_accessToken != null) {
        await _secureStorageRepository.saveAccessToken(_accessToken!);
      }

      final refreshCookie = _authService.refreshTokenCookie;
      if (refreshCookie != null) {
        await _secureStorageRepository.saveRefreshTokenCookie(refreshCookie);
      }

      final session = await _authService.checkSession();
      return _userFromSessionResponse(session);
    } on AuthException {
      await _secureStorageRepository.clearSessionTokens();
      _accessToken = null;
      rethrow;
    }
  }

  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _authService.createSession(
        email: email,
        password: password,
      );

      _accessToken = response['accessToken'];
      if (_accessToken != null) {
        await _secureStorageRepository.saveAccessToken(_accessToken!);
      }
      final refreshCookie = _authService.refreshTokenCookie;
      if (refreshCookie != null) {
        await _secureStorageRepository.saveRefreshTokenCookie(refreshCookie);
      }

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

      final response = await _authService.register(request);

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
      await _authService.deleteSession();
      _accessToken = null;
      await _secureStorageRepository.clearSessionTokens();
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

  UserModel? _userFromSessionResponse(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      return null;
    }

    final profile = data['profile'];
    final fullname = profile is Map<String, dynamic>
        ? profile['fullname']?.toString()
        : null;
    final email = data['email']?.toString() ?? '';
    final username = data['username']?.toString();

    return UserModel(
      id: data['id']?.toString() ?? '',
      email: email,
      fullName: fullname ?? username ?? email.split('@').first,
      avatarUrl: null,
    );
  }
}
