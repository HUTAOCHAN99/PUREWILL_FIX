import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:purewill/domain/model/auth_model.dart';
import 'package:purewill/domain/model/category_model.dart';

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

  Map<String, dynamic> _decodeBody(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return {'data': decoded};
  }

  Map<String, dynamic> _extractDataMap(String body) {
    final decoded = _decodeBody(body);
    final data = decoded['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return decoded;
  }

  List<dynamic> _extractDataList(String body) {
    final decoded = _decodeBody(body);
    final data = decoded['data'];
    if (data is List) {
      return data;
    }
    return const [];
  }

  String _extractErrorMessage(String body, String fallback) {
    try {
      final decoded = _decodeBody(body);
      final message = decoded['message'];
      if (message != null) {
        return message.toString();
      }
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  Future<List<CategoryModel>> getAllCategories() async {
    try {
      if (kDebugMode) print('📡 GET $baseUrl/categories');

      final response = await _client.get(
        Uri.parse('$baseUrl/categories'),
        headers: _headers,
      );

      if (kDebugMode) print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = _extractDataList(response.body);
        return data
            .whereType<Map>()
            .map(
              (json) => CategoryModel.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();
      }

      if (response.statusCode == 401) {
        throw AuthException('Unauthorized. Please login again.');
      }

      throw AuthException(
        _extractErrorMessage(response.body, 'Failed to load categories'),
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error: $e');
    }
  }

  Future<CategoryModel> getCategoryDetail(int id) async {
    try {
      if (kDebugMode) print('📡 GET $baseUrl/categories/$id');

      final response = await _client.get(
        Uri.parse('$baseUrl/categories/$id'),
        headers: _headers,
      );

      if (kDebugMode) print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return CategoryModel.fromJson(_extractDataMap(response.body));
      }

      if (response.statusCode == 401) {
        throw AuthException('Unauthorized. Please login again.');
      }
      if (response.statusCode == 404) {
        throw AuthException('Category not found');
      }

      throw AuthException(
        _extractErrorMessage(response.body, 'Failed to get category detail'),
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error: $e');
    }
  }

  Future<CategoryModel> createCategory({
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
        return CategoryModel.fromJson(_extractDataMap(response.body));
      }

      if (response.statusCode == 401) {
        throw AuthException('Unauthorized. Please login again.');
      }

      throw AuthException(
        _extractErrorMessage(response.body, 'Failed to create category'),
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error: $e');
    }
  }

  Future<CategoryModel> updateCategory({
    required int id,
    String? name,
    String? description,
  }) async {
    try {
      final body = {
        'id': id,
        if (name != null && name.isNotEmpty) 'name': name,
        if (description != null && description.isNotEmpty)
          'description': description,
      };

      if (kDebugMode) print('📡 PATCH $baseUrl/categories');
      if (kDebugMode) print('📡 Body: $body');

      final response = await _client.patch(
        Uri.parse('$baseUrl/categories'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (kDebugMode) print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return CategoryModel.fromJson(_extractDataMap(response.body));
      }

      if (response.statusCode == 401) {
        throw AuthException('Unauthorized. Please login again.');
      }
      if (response.statusCode == 404) {
        throw AuthException('Category not found');
      }

      throw AuthException(
        _extractErrorMessage(response.body, 'Failed to update category'),
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error: $e');
    }
  }

  Future<void> removeCategory(int categoryId) async {
    await deleteCategory(categoryId);
  }

  Future<void> deleteCategory(int categoryId) async {
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
        return;
      }

      if (response.statusCode == 401) {
        throw AuthException('Unauthorized. Please login again.');
      }
      if (response.statusCode == 404) {
        throw AuthException('Category not found');
      }

      throw AuthException(
        _extractErrorMessage(response.body, 'Failed to delete category'),
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> addCategory({
    required String name,
    String? description,
  }) async {
    final category = await createCategory(name: name, description: description);
    return {
      'message': 'create category successfull',
      'data': category.toJson(),
    };
  }

  Future<Map<String, dynamic>> loadUserCategories() async {
    final categories = await getAllCategories();
    return {
      'message': 'successfully get all categories',
      'data': categories.map((e) => e.toJson()).toList(),
    };
  }

  void dispose() {
    _client.close();
  }
}
