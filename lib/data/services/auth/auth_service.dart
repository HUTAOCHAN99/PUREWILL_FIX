import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:purewill/domain/model/auth_model.dart';

class AuthService {
  AuthService({http.Client? client}) : _client = client ?? http.Client() {
    final host = dotenv.env['API_HOST'] ?? 'localhost';
    final port = dotenv.env['API_PORT'] ?? '4000';
    _baseUrl = 'http://$host:$port/api';

    if (kDebugMode) {
      print('🌐 AuthService Base URL: $_baseUrl');
    }
  }

  final http.Client _client;
  late final String _baseUrl;

  String? _accessToken;
  String? _refreshTokenCookie;

  String? get accessToken => _accessToken;
  String? get refreshTokenCookie => _refreshTokenCookie;

  void setAccessToken(String token) {
    _accessToken = token;
  }

  void setRefreshTokenCookie(String cookie) {
    _refreshTokenCookie = cookie;
  }

  Future<Map<String, dynamic>> createSession({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/sessions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = _decodeBody(response);
      _accessToken = data['accessToken'] as String?;
      _refreshTokenCookie = _extractRefreshTokenCookie(response);
      return data;
    }

    if (response.statusCode == 400) {
      final error = _decodeBody(response);
      throw AuthException(
        error['message']?.toString() ?? 'user not registered',
      );
    }

    throw AuthException('Server error: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> login(String email, String password) {
    return createSession(email: email, password: password);
  }

  Future<Map<String, dynamic>> register(RegisterRequest request) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return _decodeBody(response);
    }

    if (response.statusCode == 400) {
      final error = _decodeBody(response);
      throw AuthException(
        error['message']?.toString() ?? 'user not registered',
      );
    }

    throw AuthException('Server error: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> refreshSession() async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/refresh'),
      headers: {
        'Content-Type': 'application/json',
        if (_refreshTokenCookie != null) 'Cookie': _refreshTokenCookie!,
      },
    );

    if (response.statusCode == 200) {
      final data = _decodeBody(response);
      _accessToken = data['accessToken'] as String?;

      final refreshedCookie = _extractRefreshTokenCookie(response);
      if (refreshedCookie != null) {
        _refreshTokenCookie = refreshedCookie;
      }

      return data;
    }

    final error = _decodeBody(response);

    if (response.statusCode == 401) {
      throw AuthException(
        error['message']?.toString() ?? 'refresh token is required',
      );
    }

    if (response.statusCode == 400) {
      throw AuthException(
        error['message']?.toString() ?? 'refresh token not valid',
      );
    }

    throw AuthException('Refresh failed: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> refreshToken() => refreshSession();

  Future<void> deleteSession() async {
    final response = await _client.delete(
      Uri.parse('$_baseUrl/auth/session'),
      headers: {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
        if (_refreshTokenCookie != null) 'Cookie': _refreshTokenCookie!,
      },
    );

    if (response.statusCode == 200) {
      _accessToken = null;
      _refreshTokenCookie = null;
      return;
    }

    final error = _decodeBody(response);

    if (response.statusCode == 400) {
      throw AuthException(error['message']?.toString() ?? 'user id not found');
    }

    if (response.statusCode == 500) {
      throw AuthException(
        error['message']?.toString() ?? 'delete refresh token failed',
      );
    }

    throw AuthException('Logout failed: ${response.statusCode}');
  }

  Future<void> logout() => deleteSession();

  Future<Map<String, dynamic>> checkSession({bool skipRefresh = false}) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/auth/session'),
      headers: {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      return _decodeBody(response);
    }

    if (response.statusCode == 401) {
      if (!skipRefresh && _refreshTokenCookie != null) {
        if (kDebugMode) {
          print('🔄 Access token expired. Refreshing session...');
        }

        await refreshSession();
        return checkSession(skipRefresh: true);
      }

      final error = _decodeBody(response);
      throw AuthException(error['message']?.toString() ?? 'Unauthorized');
    }

    throw AuthException('Check session failed: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getCurrentSession() => checkSession();

  Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.isEmpty) {
      return {};
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return {};
  }

  String? _extractRefreshTokenCookie(http.Response response) {
    final setCookie = response.headers['set-cookie'];
    if (setCookie == null || setCookie.isEmpty) {
      return null;
    }

    final match = RegExp(r'refreshToken=([^;]+)').firstMatch(setCookie);
    if (match == null) {
      return null;
    }

    return 'refreshToken=${match.group(1)}';
  }

  void dispose() {
    _client.close();
  }
}
