import 'package:intl/intl.dart';

/// Conversation model representing a chat session
class ConversationModel {
  final String id;
  final String userId;
  final String? title;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConversationModel({
    required this.id,
    required this.userId,
    this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final createdAtValue = json['createdAt'];
    final updatedAtValue = json['updatedAt'];
    
    return ConversationModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String?,
      createdAt: createdAtValue is String 
          ? DateTime.parse(createdAtValue as String)
          : DateTime.now(),
      updatedAt: updatedAtValue is String 
          ? DateTime.parse(updatedAtValue as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  String get displayTitle => title?.isEmpty ?? true ? 'New Conversation' : title!;
  
  String getFormattedDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(updatedAt.year, updatedAt.month, updatedAt.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(updatedAt);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(updatedAt).inDays < 7) {
      return DateFormat('EEE').format(updatedAt);
    } else {
      return DateFormat('dd/MM/yy').format(updatedAt);
    }
  }
}

/// Message model representing a chat message
class MessageModel {
  final String id;
  final String conversationId;
  final String role; // 'USER' or 'ASSISTANT'
  final String content;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final createdAtValue = json['createdAt'];
    
    return MessageModel(
      id: json['id'] as String? ?? '',
      conversationId: json['conversationId'] as String? ?? '',
      role: json['role'] as String? ?? 'USER',
      content: json['content'] as String? ?? '',
      createdAt: createdAtValue is String 
          ? DateTime.parse(createdAtValue as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversationId': conversationId,
    'role': role,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
  };

  bool get isUserMessage => role == 'USER';
  bool get isAssistantMessage => role == 'ASSISTANT';
}

/// Response model for message creation (user + assistant)
class MessageResponseModel {
  final MessageModel userMessage;
  final MessageModel assistantMessage;

  MessageResponseModel({
    required this.userMessage,
    required this.assistantMessage,
  });

  factory MessageResponseModel.fromJson(Map<String, dynamic> json) {
    return MessageResponseModel(
      userMessage: MessageModel.fromJson(json['userMessage'] as Map<String, dynamic>),
      assistantMessage: MessageModel.fromJson(json['assistantMessage'] as Map<String, dynamic>),
    );
  }
}
