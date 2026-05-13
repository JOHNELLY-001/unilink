import 'dart:async';
import '../abstracts/ai_repository.dart';
import '../../models/ai_message_model.dart';
import '../../mock/mock_ai_responses.dart';

class MockAiRepository implements AiRepository {
  // In-memory conversation history
  // Real impl: fetches from DB per userId
  final List<AiMessageModel> _history = [MockAiResponses.welcomeMessage];

  @override
  Future<AiMessageModel> sendMessage({
    required String userId,
    required String message,
    required List<AiMessageModel> conversationHistory,
  }) async {
    // Simulate AI thinking delay (1.5-2.5 seconds)
    await Future.delayed(
      Duration(milliseconds: 1500 + (message.length % 1000)),
    );
    final response = MockAiResponses.getResponse(message);
    _history.add(response);
    return response;
  }

  @override
  Future<List<AiMessageModel>> getConversationHistory(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_history);
  }

  @override
  Future<void> clearHistory(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _history.clear();
    _history.add(MockAiResponses.welcomeMessage);
  }

  @override
  Future<List<AiSuggestionChip>> getQuickSuggestions(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockAiResponses.defaultSuggestions;
  }

  @override
  Stream<String> streamResponse({
    required String userId,
    required String message,
  }) async* {
    // Simulates streaming tokens one character at a time
    // Real impl: connects to SSE endpoint and yields chunks
    final response = MockAiResponses.getResponse(message);
    final words = response.content.split(' ');
    for (final word in words) {
      await Future.delayed(const Duration(milliseconds: 60));
      yield '$word ';
    }
  }

  @override
  Future<AiMessageModel> sendVoiceMessage({
    required String userId,
    required String audioPath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 2000));
    // Mock: treat voice as a text query about careers
    return MockAiResponses.getResponse('software engineering career');
  }
}