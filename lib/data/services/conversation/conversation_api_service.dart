import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purewill/domain/model/auth_model.dart';
import 'package:purewill/domain/model/conversation_model.dart';

class ConversationApiService {
  late final String _baseUrl;
  String? _accessToken;

  ConversationApiService({http.Client? client})
    : _client = client ?? http.Client() {
    final host = dotenv.env['API_HOST'] ?? 'localhost';
    final port = dotenv.env['API_PORT'] ?? '4000';
    _baseUrl = 'http://$host:$port/api/conversations';
  }

  final http.Client _client;

  void setAccessToken(String token) {
    _accessToken = token;
  }

  String _getAuthHeader() {
    if (_accessToken == null || _accessToken!.isEmpty) {
      throw AuthException('Access token is required');
    }
    return 'Bearer $_accessToken';
  }

  /// GET /api/conversations
  /// Get list of conversations for the logged-in user
  Future<List<ConversationModel>> getConversations() async {
    final response = await _client.get(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': _getAuthHeader(),
      },
    );

    if (response.statusCode == 200) {
      final data = _decodeBody(response);
      final conversations =
          (data['data'] as List<dynamic>?)
              ?.map(
                (e) => ConversationModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [];
      return conversations;
    }

    if (response.statusCode == 401) {
      throw AuthException('Unauthorized');
    }

    throw AuthException(
      'Failed to fetch conversations: ${response.statusCode}',
    );
  }

  /// POST /api/conversations
  /// Create a new conversation
  Future<ConversationModel> createConversation({String? title}) async {
    final response = await _client.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': _getAuthHeader(),
      },
      body: jsonEncode({'title': title}),
    );

    if (response.statusCode == 201) {
      final data = _decodeBody(response);
      return ConversationModel.fromJson(data['data'] as Map<String, dynamic>);
    }

    if (response.statusCode == 401) {
      throw AuthException('Unauthorized');
    }

    if (response.statusCode == 400) {
      final error = _decodeBody(response);
      throw AuthException(error['message']?.toString() ?? 'Invalid request');
    }

    throw AuthException(
      'Failed to create conversation: ${response.statusCode}',
    );
  }

  /// GET /api/conversations/:id
  /// Get conversation detail by ID
  Future<ConversationModel> getConversationDetail(String conversationId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/$conversationId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': _getAuthHeader(),
      },
    );

    if (response.statusCode == 200) {
      final data = _decodeBody(response);
      return ConversationModel.fromJson(data['data'] as Map<String, dynamic>);
    }

    if (response.statusCode == 401) {
      throw AuthException('Unauthorized');
    }

    if (response.statusCode == 403) {
      throw AuthException(
        'Forbidden: You do not have access to this conversation',
      );
    }

    if (response.statusCode == 404) {
      throw AuthException('Conversation not found');
    }

    throw AuthException('Failed to fetch conversation: ${response.statusCode}');
  }

  /// DELETE /api/conversations/:id
  /// Delete conversation by ID
  Future<void> deleteConversation(String conversationId) async {
    final response = await _client.delete(
      Uri.parse('$_baseUrl/$conversationId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': _getAuthHeader(),
      },
    );

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 401) {
      throw AuthException('Unauthorized');
    }

    if (response.statusCode == 403) {
      throw AuthException(
        'Forbidden: You do not have access to this conversation',
      );
    }

    if (response.statusCode == 404) {
      throw AuthException('Conversation not found');
    }

    throw AuthException(
      'Failed to delete conversation: ${response.statusCode}',
    );
  }

  /// GET /api/conversations/:id/messages
  /// Get messages for a conversation with pagination support
  Future<List<MessageModel>> getMessages({
    required String conversationId,
    int limit = 10,
    String? cursor,
  }) async {
    final uri = Uri.parse('$_baseUrl/$conversationId/messages').replace(
      queryParameters: {
        'limit': limit.toString(),
        if (cursor != null) 'cursor': cursor,
      },
    );

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': _getAuthHeader(),
      },
    );

    if (response.statusCode == 200) {
      final data = _decodeBody(response);
      final messages =
          (data['data'] as List<dynamic>?)
              ?.map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      return messages;
    }

    if (response.statusCode == 401) {
      throw AuthException('Unauthorized');
    }

    if (response.statusCode == 403) {
      throw AuthException(
        'Forbidden: You do not have access to this conversation',
      );
    }

    if (response.statusCode == 404) {
      throw AuthException('Conversation not found');
    }

    throw AuthException('Failed to fetch messages: ${response.statusCode}');
  }

  /// POST /api/conversations/:id/messages
  /// Create a message and get AI response
  Future<MessageResponseModel> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/$conversationId/messages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': _getAuthHeader(),
      },
      body: jsonEncode({'content': content}),
    );

    print(response.body);

    if (response.statusCode == 201) {
      final data = _decodeBody(response);
      return MessageResponseModel.fromJson(
        data['data'] as Map<String, dynamic>,
      );
    }

    if (response.statusCode == 401) {
      throw AuthException('Unauthorized');
    }

    if (response.statusCode == 403) {
      throw AuthException(
        'Forbidden: You do not have access to this conversation',
      );
    }

    if (response.statusCode == 404) {
      throw AuthException('Conversation not found');
    }

    if (response.statusCode == 429) {
      throw AuthException('Too many requests. Please try again later.');
    }

    if (response.statusCode == 400) {
      final error = _decodeBody(response);
      throw AuthException(error['message']?.toString() ?? 'Invalid message');
    }

    if (response.statusCode == 500) {
      throw AuthException('Server error: Failed to generate AI response');
    }

    throw AuthException('Failed to send message: ${response.statusCode}');
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  void dispose() {
    _client.close();
  }
}
