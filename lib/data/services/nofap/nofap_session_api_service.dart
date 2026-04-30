import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:purewill/data/repository/auth_repository.dart';
import 'package:purewill/data/services/auth/auth_refresh_client.dart';
import 'package:purewill/domain/model/auth_model.dart';

class NofapSessionApiService {
  NofapSessionApiService({
    http.Client? client,
    AuthRepository? authRepository,
  }) {
    _client = authRepository != null
        ? AuthRefreshClient(
            client ?? http.Client(),
            authRepository,
            onTokenRefreshed: (token) {
              _accessToken = token;
            },
          )
        : (client ?? http.Client());
    final host = dotenv.env['API_HOST'] ?? 'localhost';
    final port = dotenv.env['API_PORT'] ?? '4000';
    baseUrl = 'http://$host:$port/api';

    if (kDebugMode) {
      print('🌐 Nofap Session API Base URL: $baseUrl');
    }
  }

  late final String baseUrl;
  late final http.Client _client;
  String? _accessToken;

  void setAccessToken(String token) {
    _accessToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  Future<Map<String, dynamic>> getCurrentSession() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/nofap-sessions/current'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return _decodeBody(response);
    }

    throw AuthException(
      _extractErrorMessage(
        response.body,
        'Failed to get current nofap session: ${response.statusCode}',
      ),
    );
  }

  Future<Map<String, dynamic>> getSessionDetail(int sessionId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/nofap-sessions/$sessionId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return _decodeBody(response);
    }

    throw AuthException(
      _extractErrorMessage(
        response.body,
        'Failed to get nofap session detail: ${response.statusCode}',
      ),
    );
  }

  Future<Map<String, dynamic>> createSession() async {
    final response = await _client.post(
      Uri.parse('$baseUrl/nofap-sessions'),
      headers: _headers,
      body: jsonEncode(<String, dynamic>{}),
    );

    if (response.statusCode == 201) {
      return _decodeBody(response);
    }

    throw AuthException(
      _extractErrorMessage(
        response.body,
        'Failed to create nofap session: ${response.statusCode}',
      ),
    );
  }

  Future<Map<String, dynamic>> updateCurrentSession({
    DateTime? startDate,
    DateTime? endDate,
    String? relapseNotes,
  }) async {
    final body = <String, dynamic>{
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
      if (relapseNotes != null) 'relapseNotes': relapseNotes,
    };

    final response = await _client.patch(
      Uri.parse('$baseUrl/nofap-sessions/current'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return _decodeBody(response);
    }

    throw AuthException(
      _extractErrorMessage(
        response.body,
        'Failed to update current nofap session: ${response.statusCode}',
      ),
    );
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.isEmpty) return {};

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return {};
  }

  String _extractErrorMessage(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic> && decoded['message'] != null) {
        return decoded['message'].toString();
      }
    } catch (_) {
      return fallback;
    }
    return fallback;
  }

  void dispose() {
    _client.close();
  }
}
