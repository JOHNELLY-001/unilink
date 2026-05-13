import '../../models/ai_message_model.dart';

abstract class AiRepository {
  /// Send a message and get an AI response.
  /// In production: POST to AI service endpoint.
  Future<AiMessageModel> sendMessage({
    required String userId,
    required String message,
    required List<AiMessageModel> conversationHistory,
  });

  /// Fetch AI conversation history for the current user.
  Future<List<AiMessageModel>> getConversationHistory(String userId);

  /// Clear conversation history.
  Future<void> clearHistory(String userId);

  /// Get AI-generated quick prompt suggestions.
  Future<List<AiSuggestionChip>> getQuickSuggestions(String userId);

  /// Stream AI response tokens for streaming UX.
  /// In production: connect to SSE (Server-Sent Events) endpoint.
  Stream<String> streamResponse({
    required String userId,
    required String message,
  });

  /// Submit voice input and get text + AI response.
  /// In production: pipe audio bytes to voice AI service.
  Future<AiMessageModel> sendVoiceMessage({
    required String userId,
    required String audioPath,
  });
}