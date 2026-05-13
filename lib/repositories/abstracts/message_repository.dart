import '../../models/message_model.dart';

abstract class MessageRepository {
  /// Fetch all conversations for the current user.
  Future<List<ConversationModel>> getConversations(String userId);

  /// Fetch messages in a conversation (paginated).
  Future<List<MessageModel>> getMessages({
    required String conversationId,
    int page = 1,
    int pageSize = 30,
  });

  /// Send a text message.
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
    String? mediaUrl,
  });

  /// Mark all messages in a conversation as read.
  Future<void> markAsRead(String conversationId);

  /// Get or create a conversation with another user.
  Future<ConversationModel> getOrCreateConversation({
    required String currentUserId,
    required String otherUserId,
  });

  /// Get total unread count across all conversations.
  Future<int> getTotalUnreadCount(String userId);

  /// Stream of new messages for a conversation (for real-time).
  /// Connect to WebSocket or Supabase Realtime when backend ready.
  Stream<MessageModel> messageStream(String conversationId);

  /// Stream of conversation list updates.
  Stream<List<ConversationModel>> conversationStream(String userId);
}