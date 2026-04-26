// lib/data/services/auth/auth_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purewill/domain/model/auth_model.dart';

class AuthApiService {
  late String baseUrl;
  String? _accessToken;
  static bool _isInitialized = false;
  
  AuthApiService() {
    _initBaseUrl();
  }
  
  Future<void> _initBaseUrl() async {
    if (_isInitialized) return;
    
    final host = dotenv.env['API_HOST'] ?? 'localhost';
    final port = dotenv.env['API_PORT'] ?? '4000';
    baseUrl = 'http://$host:$port/api';
    if (kDebugMode) print('🌐 API Base URL: $baseUrl');
    _isInitialized = true;
  }
  
  String? get accessToken => _accessToken;
  
  void setAccessToken(String token) {
    _accessToken = token;
  }
  
  final http.Client _client = http.Client();
  
  // ============ AUTH ENDPOINTS ============
  
  /// POST /api/auth/sessions - Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/auth/sessions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['accessToken'];
      return data;
    } else if (response.statusCode == 400) {
      final error = jsonDecode(response.body);
      throw AuthException(error['message'] ?? 'Login failed');
    } else {
      throw AuthException('Server error: ${response.statusCode}');
    }
  }
  
  /// POST /api/users - Register
  Future<Map<String, dynamic>> register(RegisterRequest request) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 400) {
      final error = jsonDecode(response.body);
      throw AuthException(error['message'] ?? 'Registration failed');
    } else {
      throw AuthException('Server error: ${response.statusCode}');
    }
  }
  
  /// POST /api/auth/refresh - Refresh Token
  Future<Map<String, dynamic>> refreshToken() async {
    final response = await _client.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['accessToken'];
      return data;
    } else if (response.statusCode == 401) {
      throw AuthException('Refresh token is required');
    } else {
      throw AuthException('Refresh failed: ${response.statusCode}');
    }
  }
  
  /// DELETE /api/auth/session - Logout
  Future<void> logout() async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/auth/session'),
      headers: {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      },
    );
    
    if (response.statusCode == 200) {
      _accessToken = null;
    } else if (response.statusCode == 400) {
      final error = jsonDecode(response.body);
      throw AuthException(error['message'] ?? 'User id not found');
    } else {
      throw AuthException('Logout failed: ${response.statusCode}');
    }
  }
  
  // ============ USER PROFILE ============
  
  /// GET /api/users/:id - Get user profile
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      },
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw AuthException('Failed to get user: ${response.statusCode}');
    }
  }
  
  void dispose() {
    _client.close();
  }
}