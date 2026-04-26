// lib/data/services/habits/habit_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:purewill/domain/model/auth_model.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class HabitApiService {
  late final String baseUrl;
  String? _accessToken;
  
  HabitApiService() {
    final host = dotenv.env['API_HOST'] ?? 'localhost';
    final port = dotenv.env['API_PORT'] ?? '4000';
    baseUrl = 'http://$host:$port/api';
    if (kDebugMode) {
      print('🌐 Habit API Base URL: $baseUrl');
    }
  }
  
  void setAccessToken(String token) {
    _accessToken = token;
    if (kDebugMode) {
      print('🔐 HabitApiService: Access token set');
    }
  }
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };
  
  final http.Client _client = http.Client();
  
  // ==================== HABIT ENDPOINTS ====================
  
  /// GET /api/users/:id/habits - Get user habits
  Future<Map<String, dynamic>> getUserHabits(String userId) async {
    try {
      if (kDebugMode) print('📡 GET $baseUrl/users/$userId/habits');
      
      final response = await _client.get(
        Uri.parse('$baseUrl/users/$userId/habits'),
        headers: _headers,
      );
      
      if (kDebugMode) print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw AuthException('Unauthorized. Please login again.');
      } else {
        throw AuthException('Failed to get habits: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error: $e');
    }
  }
  
  /// GET /api/habits/:id - Get habit detail
  Future<Map<String, dynamic>> getHabitDetail(int habitId) async {
    try {
      if (kDebugMode) print('📡 GET $baseUrl/habits/$habitId');
      
      final response = await _client.get(
        Uri.parse('$baseUrl/habits/$habitId'),
        headers: _headers,
      );
      
      if (kDebugMode) print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw AuthException('Unauthorized. Please login again.');
      } else if (response.statusCode == 404) {
        throw AuthException('Habit not found');
      } else {
        throw AuthException('Failed to get habit detail: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error: $e');
    }
  }
  
  /// GET /api/habits/:id/reminder-settings - Get habit reminder settings
  Future<Map<String, dynamic>> getHabitReminderSettings(int habitId) async {
    try {
      if (kDebugMode) print('📡 GET $baseUrl/habits/$habitId/reminder-settings');
      
      final response = await _client.get(
        Uri.parse('$baseUrl/habits/$habitId/reminder-settings'),
        headers: _headers,
      );
      
      if (kDebugMode) print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw AuthException('Unauthorized. Please login again.');
      } else if (response.statusCode == 404) {
        throw AuthException('Habit not found');
      } else {
        return {'data': []};
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      return {'data': []};
    }
  }
  
  /// POST /api/habits - Create habit
  Future<Map<String, dynamic>> createHabit(HabitModel habit) async {
    try {
      final body = {
        'name': habit.name,
        if (habit.notes != null && habit.notes!.isNotEmpty) 'notes': habit.notes,
        'startDate': habit.startDate.toIso8601String(),
        if (habit.endDate != null) 'endDate': habit.endDate!.toIso8601String(),
        'categoryId': habit.categoryId,
        'frequencyType': habit.frequency.toUpperCase(),
        if (habit.targetValue != null) 'targetValue': habit.targetValue,
        'reminderEnabled': habit.reminderEnabled,
      };
      
      if (kDebugMode) print('📡 POST $baseUrl/habits');
      if (kDebugMode) print('📡 Body: $body');
      
      final response = await _client.post(
        Uri.parse('$baseUrl/habits'),
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
        throw AuthException(error['message'] ?? 'Failed to create habit');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error: $e');
    }
  }
  
  /// PATCH /api/habits - Update habit
  Future<Map<String, dynamic>> updateHabit(int habitId, Map<String, dynamic> updates) async {
    try {
      final body = {
        'id': habitId,
        ...updates,
      };
      
      if (kDebugMode) print('📡 PATCH $baseUrl/habits');
      if (kDebugMode) print('📡 Body: $body');
      
      final response = await _client.patch(
        Uri.parse('$baseUrl/habits'),
        headers: _headers,
        body: jsonEncode(body),
      );
      
      if (kDebugMode) print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw AuthException('Unauthorized. Please login again.');
      } else if (response.statusCode == 403) {
        throw AuthException('Forbidden to update this habit');
      } else if (response.statusCode == 404) {
        throw AuthException('Habit not found');
      } else {
        final error = jsonDecode(response.body);
        throw AuthException(error['message'] ?? 'Failed to update habit');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error: $e');
    }
  }
  
  /// DELETE /api/habits - Delete habit
  Future<Map<String, dynamic>> deleteHabit(int habitId) async {
    try {
      if (kDebugMode) print('📡 DELETE $baseUrl/habits');
      if (kDebugMode) print('📡 Body: {"id": $habitId}');
      
      final response = await _client.delete(
        Uri.parse('$baseUrl/habits'),
        headers: _headers,
        body: jsonEncode({'id': habitId}),
      );
      
      if (kDebugMode) print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw AuthException('Unauthorized. Please login again.');
      } else if (response.statusCode == 403) {
        throw AuthException('Forbidden to delete this habit');
      } else if (response.statusCode == 404) {
        throw AuthException('Habit not found');
      } else {
        final error = jsonDecode(response.body);
        throw AuthException(error['message'] ?? 'Failed to delete habit');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error: $e');
    }
  }
  
  // ==================== CATEGORY ENDPOINTS ====================
  
  /// GET /api/users/:id/categories - Get user categories
  Future<Map<String, dynamic>> getUserCategories(String userId) async {
    try {
      if (kDebugMode) print('📡 GET $baseUrl/users/$userId/categories');
      
      final response = await _client.get(
        Uri.parse('$baseUrl/users/$userId/categories'),
        headers: _headers,
      );
      
      if (kDebugMode) print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw AuthException('Unauthorized. Please login again.');
      } else {
        throw AuthException('Failed to get categories: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error: $e');
    }
  }
  
  /// POST /api/categories - Create category
  Future<Map<String, dynamic>> createCategory(String name, {String? description}) async {
    try {
      final body = {
        'name': name,
        if (description != null && description.isNotEmpty) 'description': description,
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
        throw AuthException(error['message'] ?? 'Failed to create category');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error: $e');
    }
  }
  
  /// PATCH /api/categories - Update category
  Future<Map<String, dynamic>> updateCategory(int id, {String? name, String? description}) async {
    try {
      final body = {
        'id': id,
        if (name != null && name.isNotEmpty) 'name': name,
        if (description != null && description.isNotEmpty) 'description': description,
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
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw AuthException('Unauthorized. Please login again.');
      } else if (response.statusCode == 404) {
        throw AuthException('Category not found');
      } else {
        final error = jsonDecode(response.body);
        throw AuthException(error['message'] ?? 'Failed to update category');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error: $e');
    }
  }
  
  /// DELETE /api/categories - Delete category
  Future<Map<String, dynamic>> deleteCategory(int id) async {
    try {
      if (kDebugMode) print('📡 DELETE $baseUrl/categories');
      if (kDebugMode) print('📡 Body: {"id": $id}');
      
      final response = await _client.delete(
        Uri.parse('$baseUrl/categories'),
        headers: _headers,
        body: jsonEncode({'id': id}),
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
  
  // ==================== UNIT ENDPOINTS ====================
  
  /// GET /api/units - Get all units
  Future<Map<String, dynamic>> getUnits() async {
    try {
      if (kDebugMode) print('📡 GET $baseUrl/units');
      
      final response = await _client.get(
        Uri.parse('$baseUrl/units'),
        headers: _headers,
      );
      
      if (kDebugMode) print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'data': []};
      }
    } catch (e) {
      return {'data': []};
    }
  }
  
  void dispose() {
    _client.close();
  }
}