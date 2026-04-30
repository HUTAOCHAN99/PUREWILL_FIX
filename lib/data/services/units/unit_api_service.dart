import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purewill/data/repository/auth_repository.dart';
import 'package:purewill/domain/model/auth_model.dart';
import 'package:purewill/domain/model/target_unit_model.dart';
import 'package:purewill/data/services/auth/auth_refresh_client.dart';

class UnitApiService {
  late final String baseUrl;
  String? _accessToken;
  late final http.Client _client;

  UnitApiService({http.Client? client, AuthRepository? authRepository}) {
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
    baseUrl = 'http://$host:$port/api/units';
  }

  void setAccessToken(String token) {
    _accessToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  Map<String, dynamic> _decodeBody(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    return {'data': decoded};
  }

  Map<String, dynamic> _extractDataMap(String body) {
    final decoded = _decodeBody(body);
    final data = decoded['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return decoded;
  }

  List<dynamic> _extractDataList(String body) {
    final decoded = _decodeBody(body);
    final data = decoded['data'];
    if (data is List) return data;
    return const [];
  }

  Future<List<TargetUnitModel>> getAllUnits() async {
    try {
      if (kDebugMode) print('📡 GET $baseUrl');

      final response = await _client.get(Uri.parse(baseUrl), headers: _headers);

      if (kDebugMode) print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = _extractDataList(response.body);
        return data
            .whereType<Map>()
            .map(
              (json) =>
                  TargetUnitModel.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();
      }

      if (response.statusCode == 401) {
        throw AuthException('Unauthorized. Please login again.');
      }

      throw AuthException(
        _extractErrorMessage(response.body, 'Failed to fetch units'),
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error: $e');
    }
  }

  Future<TargetUnitModel> getUnitDetail(int id) async {
    try {
      if (kDebugMode) print('📡 GET $baseUrl/$id');

      final response = await _client.get(
        Uri.parse('$baseUrl/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return TargetUnitModel.fromJson(_extractDataMap(response.body));
      }

      if (response.statusCode == 401) {
        throw AuthException('Unauthorized. Please login again.');
      }
      if (response.statusCode == 404) {
        throw AuthException('Unit not found');
      }

      throw AuthException(
        _extractErrorMessage(response.body, 'Failed to fetch unit detail'),
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error: $e');
    }
  }

  Future<TargetUnitModel> createUnit({
    required String name,
    String? abbreviation,
  }) async {
    try {
      final body = {
        'name': name,
        if (abbreviation != null && abbreviation.isNotEmpty)
          'abbreviation': abbreviation,
      };

      if (kDebugMode) print('📡 POST $baseUrl');

      final response = await _client.post(
        Uri.parse(baseUrl),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        return TargetUnitModel.fromJson(_extractDataMap(response.body));
      }

      if (response.statusCode == 401) {
        throw AuthException('Unauthorized. Please login again.');
      }

      throw AuthException(
        _extractErrorMessage(response.body, 'Failed to create unit'),
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error: $e');
    }
  }

  Future<TargetUnitModel> updateUnit({
    required int id,
    String? name,
    String? abbreviation,
  }) async {
    try {
      final body = {
        'id': id,
        if (name != null && name.isNotEmpty) 'name': name,
        if (abbreviation != null && abbreviation.isNotEmpty)
          'abbreviation': abbreviation,
      };

      if (kDebugMode) print('📡 PATCH $baseUrl');

      final response = await _client.patch(
        Uri.parse(baseUrl),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return TargetUnitModel.fromJson(_extractDataMap(response.body));
      }

      if (response.statusCode == 401) {
        throw AuthException('Unauthorized. Please login again.');
      }
      if (response.statusCode == 404) {
        throw AuthException('Unit not found');
      }

      throw AuthException(
        _extractErrorMessage(response.body, 'Failed to update unit'),
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error: $e');
    }
  }

  Future<void> deleteUnit(int id) async {
    try {
      if (kDebugMode) print('📡 DELETE $baseUrl');

      final response = await _client.delete(
        Uri.parse(baseUrl),
        headers: _headers,
        body: jsonEncode({'id': id}),
      );

      if (response.statusCode == 200) return;

      if (response.statusCode == 401) {
        throw AuthException('Unauthorized. Please login again.');
      }
      if (response.statusCode == 404) {
        throw AuthException('Unit not found');
      }

      throw AuthException(
        _extractErrorMessage(response.body, 'Failed to delete unit'),
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error: $e');
    }
  }

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
}
