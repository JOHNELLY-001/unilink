import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_message_model.dart';
import 'repository_providers.dart';
import 'auth_provider.dart';

// ─── AI Chat State ────────────────────────────────────────────────────────

class AiChatState {
  final List<AiMessageModel> messages;
  final bool isTyping;
  final String? error;

  const AiChatState({
    this.messages = const [],
    this.isTyping = false,
    this.error,
  });

  AiChatState copyWith({
    List<AiMessageModel>? messages,
    bool? isTyping,
    String? error,
  }) =>
      AiChatState(
        messages: messages ?? this.messages,
        isTyping: isTyping ?? this.isTyping,
        error: error,
      );
}

class AiChatNotifier extends StateNotifier<AiChatState> {
  final Ref _ref;

  AiChatNotifier(this._ref) : super(const AiChatState()) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final repo = _ref.read(aiRepositoryProvider);
    final user = _ref.read(currentUserProvider);
    if (user == null) return;
    final history = await repo.getConversationHistory(user.id);
    state = state.copyWith(messages: history);
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    // Add user message immediately to chat
    final userMsg = AiMessageModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      role: AiMessageRole.user,
      createdAt: DateTime.now(),
    );

    // Add loading indicator
    final loadingMsg = AiMessageModel.loading();

    state = state.copyWith(
      messages: [...state.messages, userMsg, loadingMsg],
      isTyping: true,
    );

    try {
      final repo = _ref.read(aiRepositoryProvider);
      final response = await repo.sendMessage(
        userId: user.id,
        message: content,
        conversationHistory: state.messages
            .where((m) => !m.isLoading)
            .toList(),
      );

      // Replace loading indicator with real response
      final updatedMessages = state.messages
          .where((m) => !m.isLoading)
          .toList()
        ..add(response);

      state = state.copyWith(
        messages: updatedMessages,
        isTyping: false,
      );
    } catch (e) {
      final updatedMessages =
      state.messages.where((m) => !m.isLoading).toList();
      state = state.copyWith(
        messages: updatedMessages,
        isTyping: false,
        error: 'Failed to get response. Please try again.',
      );
    }
  }

  Future<void> clearHistory() async {
    final repo = _ref.read(aiRepositoryProvider);
    final user = _ref.read(currentUserProvider);
    if (user == null) return;
    await repo.clearHistory(user.id);
    state = const AiChatState();
    await _loadHistory();
  }

  void clearError() => state = state.copyWith(error: null);
}

final aiChatProvider =
StateNotifierProvider<AiChatNotifier, AiChatState>(
      (ref) => AiChatNotifier(ref),
);

final aiSuggestionsProvider =
FutureProvider<List<AiSuggestionChip>>((ref) async {
  final repo = ref.read(aiRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return repo.getQuickSuggestions(user?.id ?? 'guest');
});