import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/data/repository/conversation_repository.dart';
import 'package:purewill/data/services/conversation/conversation_api_service.dart';
import 'package:purewill/domain/model/conversation_model.dart';
import 'package:purewill/ui/auth/auth_provider.dart';

// Fixed for Riverpod v3 with AsyncNotifier

/// Provider for ConversationApiService
final conversationApiServiceProvider = Provider<ConversationApiService>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final service = ConversationApiService();
  if (authRepo.accessToken != null) {
    service.setAccessToken(authRepo.accessToken!);
  }
  return service;
});

/// Provider for ConversationRepository
final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  final apiService = ref.watch(conversationApiServiceProvider);
  return ConversationRepository(apiService);
});

/// Provider for fetching all conversations
final conversationsProvider = FutureProvider<List<ConversationModel>>((
  ref,
) async {
  final repository = ref.watch(conversationRepositoryProvider);
  return repository.getConversations();
});

/// Provider for conversation detail by ID
final conversationDetailProvider =
    FutureProvider.family<ConversationModel, String>((
      ref,
      conversationId,
    ) async {
      final repository = ref.watch(conversationRepositoryProvider);
      return repository.getConversationDetail(conversationId);
    });

/// Provider for messages in a conversation
final conversationMessagesProvider =
    FutureProvider.family<List<MessageModel>, String>((
      ref,
      conversationId,
    ) async {
      final repository = ref.watch(conversationRepositoryProvider);
      return repository.getMessages(conversationId: conversationId);
    });

/// State notifier for managing conversation operations
class ConversationNotifier extends AsyncNotifier<List<ConversationModel>> {
  late ConversationRepository _repository;

  @override
  Future<List<ConversationModel>> build() async {
    _repository = ref.watch(conversationRepositoryProvider);
    return await _repository.getConversations();
  }

  /// Create a new conversation
  Future<ConversationModel?> createConversation({String? title}) async {
    try {
      final conversation = await _repository.createConversation(title: title);

      // Refresh the list
      await refresh();

      return conversation;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  /// Delete a conversation
  Future<bool> deleteConversation(String conversationId) async {
    try {
      await _repository.deleteConversation(conversationId);

      // Refresh the list
      await refresh();

      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Refresh conversations list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getConversations());
  }
}

/// Provider for conversation operations state notifier
final conversationNotifierProvider =
    AsyncNotifierProvider<ConversationNotifier, List<ConversationModel>>(
      ConversationNotifier.new,
    );

/// State notifier for managing messages in a conversation
class ConversationMessagesNotifier extends AsyncNotifier<List<MessageModel>> {
  late ConversationRepository _repository;
  late String _conversationId;

  @override
  Future<List<MessageModel>> build() async {
    _repository = ref.watch(conversationRepositoryProvider);
    return await _repository.getMessages(conversationId: _conversationId);
  }

  /// Set conversation ID before loading
  void setConversationId(String conversationId) {
    _conversationId = conversationId;
  }

  /// Send a message and get AI response
  Future<bool> sendMessage(String content) async {
    try {
      final response = await _repository.sendMessage(
        conversationId: _conversationId,
        content: content,
      );

      // Add both messages to the current list
      final currentMessages = state.maybeWhen(
        data: (messages) => messages,
        orElse: () => <MessageModel>[],
      );

      final updatedMessages = [
        ...currentMessages,
        response.userMessage,
        response.assistantMessage,
      ];

      state = AsyncValue.data(updatedMessages);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Refresh messages for the conversation
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.getMessages(conversationId: _conversationId),
    );
  }
}

/// Provider for conversation messages state notifier
final conversationMessagesNotifierProvider =
    AsyncNotifierProvider.family<
      ConversationMessagesNotifier,
      List<MessageModel>,
      String
    >(
      (conversationId) =>
          ConversationMessagesNotifier()..setConversationId(conversationId),
    );
