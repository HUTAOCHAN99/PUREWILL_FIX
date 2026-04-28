import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:purewill/domain/model/motivation_model.dart';

class MotivationService {
  static const String _baseUrl = 'https://zenquotes.io/api/random';

  MotivationService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<MotivationModel> getRandomMotivation() async {
    try {
      final response = await _client
          .get(Uri.parse(_baseUrl))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => http.Response(
              jsonEncode([
                {'q': 'Every moment is a fresh beginning.', 'a': 'T.S. Eliot'},
              ]),
              200,
            ),
          );

      print(response.body);
      if (response.statusCode == 200) {
        print("get random motivation 200 OKE");
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return MotivationModel.fromJson(data[0] as Map<String, dynamic>);
        }
      }

      // Fallback motivation if API fails
      return MotivationModel(
        quote: 'You are stronger than you think.',
        author: 'Unknown',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching motivation: $e');
      }

      // Return fallback motivation on error
      return MotivationModel(
        quote: 'Every day is a new opportunity to improve.',
        author: 'Unknown',
      );
    }
  }
}
