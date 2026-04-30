import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purewill/data/repository/auth_repository.dart';
import 'package:purewill/data/services/auth/auth_refresh_client.dart';

class ReminderApiService {
  late final String baseUrl;
  String? _accessToken;
  late final http.Client _client;

  ReminderApiService({http.Client? client, AuthRepository? authRepository}) {
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
      print('🌐 Reminder API Base URL: $baseUrl');
    }
  }

  void setAccessToken(String token) {
    _accessToken = token;
    if (kDebugMode) print('🔐 ReminderApiService: Access token set');
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  String _extractErrorMessage(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic> && decoded['message'] != null) {
        return decoded['message'].toString();
      }
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  Map<String, dynamic> _decodeBodyMap(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return {'data': decoded};
  }

  Map<String, dynamic> _extractDataMap(String body) {
    final decoded = _decodeBodyMap(body);
    final data = decoded['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return decoded;
  }

  List<Map<String, dynamic>> _extractDataList(String body) {
    final decoded = _decodeBodyMap(body);
    final data = decoded['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  Future<List<Map<String, dynamic>>> getHabitReminderSettings(
    int habitId,
  ) async {
    try {
      if (kDebugMode)
        print('📡 GET $baseUrl/habits/$habitId/reminder-settings');

      final response = await _client.get(
        Uri.parse('$baseUrl/habits/$habitId/reminder-settings'),
        headers: _headers,
      );

      if (kDebugMode) print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return _extractDataList(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 404) {
        return const [];
      } else {
        throw Exception(
          _extractErrorMessage(
            response.body,
            'Failed to get habit reminder settings',
          ),
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getReminderSetting(int id) async {
    try {
      if (kDebugMode) print('📡 GET $baseUrl/reminder-settings/$id');

      final response = await _client.get(
        Uri.parse('$baseUrl/reminder-settings/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return _extractDataMap(response.body);
      }

      if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      }
      if (response.statusCode == 404) {
        throw Exception('Reminder not found');
      }

      throw Exception(
        _extractErrorMessage(response.body, 'Failed to get reminder'),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createReminderSetting(
    Map<String, dynamic> body,
  ) async {
    try {
      if (kDebugMode) print('📡 POST $baseUrl/reminder-settings');
      if (kDebugMode) print('📡 Body: $body');

      final response = await _client.post(
        Uri.parse('$baseUrl/reminder-settings'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (kDebugMode) print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 201) {
        return _extractDataMap(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 400) {
        throw Exception(_extractErrorMessage(response.body, 'Bad request'));
      } else {
        throw Exception(
          _extractErrorMessage(response.body, 'Failed to create reminder'),
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateReminderSetting(
    int id,
    Map<String, dynamic> updates,
  ) async {
    try {
      if (kDebugMode) print('📡 PATCH $baseUrl/reminder-settings/$id');
      if (kDebugMode) print('📡 Body: $updates');

      final response = await _client.patch(
        Uri.parse('$baseUrl/reminder-settings/$id'),
        headers: _headers,
        body: jsonEncode(updates),
      );

      if (kDebugMode) print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return _extractDataMap(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 400) {
        throw Exception(_extractErrorMessage(response.body, 'Bad request'));
      } else if (response.statusCode == 404) {
        throw Exception('Reminder not found');
      } else {
        throw Exception(
          _extractErrorMessage(response.body, 'Failed to update reminder'),
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteReminderSetting(int id) async {
    try {
      if (kDebugMode) print('📡 DELETE $baseUrl/reminder-settings/$id');

      final response = await _client.delete(
        Uri.parse('$baseUrl/reminder-settings/$id'),
        headers: _headers,
      );

      if (kDebugMode) print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 400) {
        throw Exception(_extractErrorMessage(response.body, 'Bad request'));
      } else if (response.statusCode == 404) {
        throw Exception('Reminder not found');
      } else {
        throw Exception(
          _extractErrorMessage(response.body, 'Failed to delete reminder'),
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
