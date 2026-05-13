import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import 'repository_providers.dart';
import 'auth_provider.dart';

final conversationsProvider =
FutureProvider<List<ConversationModel>>((ref) async {
  final repo = ref.read(messageRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return repo.getConversations(user.id);
});

final messagesProvider =
FutureProvider.family<List<MessageModel>, String>(
        (ref, conversationId) async {
      final repo = ref.read(messageRepositoryProvider);
      return repo.getMessages(conversationId: conversationId);
    });

final totalUnreadCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.read(messageRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;
  return repo.getTotalUnreadCount(user.id);
});