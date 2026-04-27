import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:purewill/domain/model/auth_model.dart';

class CategoryApiService {
  late final String baseUrl;
  String? _accessToken;
  final http.Client _client = http.Client();

  CategoryApiService() {
    final host = dotenv.env['API_HOST'] ?? 'localhost';
    final port = dotenv.env['API_PORT'] ?? '4000';
    baseUrl = 'http://$host:$port/api';

    if (kDebugMode) {
      print('🌐 Category API Base URL: $baseUrl');
    }
  }

  void setAccessToken(String token) {
    _accessToken = token;
    if (kDebugMode) {
      print('🔐 CategoryApiService: Access token set');
    }
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  Future<Map<String, dynamic>> addCategory({
    required String name,
    String? description,
  }) async {
    try {
      final body = {
        'name': name,
        if (description != null && description.isNotEmpty)
          'description': description,
      };

      if (kDebugMode) print('📡 POST $baseUrl/categories');
      if (kDebugMode) print('📡 Body: $body');

      final response = await _client.post(
        Uri.parse('$baseUrl/categories'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (kDebugMode) print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw AuthException('Unauthorized. Please login again.');
      } else {
        final error = jsonDecode(response.body);
        throw AuthException(error['message'] ?? 'Failed to add category');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> loadUserCategories() async {
    try {
      if (kDebugMode) print('📡 GET $baseUrl/me/categories');

      final response = await _client.get(
        Uri.parse('$baseUrl/me/categories'),
        headers: _headers,
      );

      if (kDebugMode) print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw AuthException('Unauthorized. Please login again.');
      } else {
        throw AuthException(
          'Failed to load user categories: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> deleteCategory(int categoryId) async {
    try {
      if (kDebugMode) print('📡 DELETE $baseUrl/categories');
      if (kDebugMode) print('📡 Body: {"id": $categoryId}');

      final response = await _client.delete(
        Uri.parse('$baseUrl/categories'),
        headers: _headers,
        body: jsonEncode({'id': categoryId}),
      );

      if (kDebugMode) print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw AuthException('Unauthorized. Please login again.');
      } else if (response.statusCode == 404) {
        throw AuthException('Category not found');
      } else {
        final error = jsonDecode(response.body);
        throw AuthException(error['message'] ?? 'Failed to delete category');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
