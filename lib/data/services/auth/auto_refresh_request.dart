import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:purewill/data/repository/auth_repository.dart';

Future<http.Response> sendWithAutoRefresh({
  required Future<http.Response> Function() request,
  required AuthRepository? authRepository,
  required void Function(String token) updateAccessToken,
}) async {
  final response = await request();

  if (response.statusCode != 401 || authRepository == null) {
    return response;
  }

  if (kDebugMode) {
    print('🔄 Access token expired. Refreshing session...');
  }

  final refreshedToken = await authRepository.refreshAccessToken();
  if (refreshedToken == null || refreshedToken.isEmpty) {
    return response;
  }

  updateAccessToken(refreshedToken);
  return request();
}
