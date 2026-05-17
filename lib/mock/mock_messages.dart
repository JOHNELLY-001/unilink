import '../models/message_model.dart';

/// Provides additional mock conversation data
/// beyond what's already in MockMessageRepository.
class MockMessages {
  MockMessages._();

  static List<ConversationModel> get conversations =>
      MockMessageRepository._buildMockConversations();
}

// Re-export so other mocks can access the builder cleanly.
// The actual data lives in MockMessageRepository
// to keep the single source of truth pattern.
class MockMessageRepository {
  static List<ConversationModel> _buildMockConversations() => [
    ConversationModel(
      id: 'conv_001',
      participantId: 'mtr_001',
      participantName: 'Grace Kimaro',
      participantAvatarUrl:
      'https://i.pravatar.cc/150?img=23',
      participantRole: 'mentor',
      lastMessage: MessageModel(
        id: 'msg_004',
        conversationId: 'conv_001',
        senderId: 'mtr_001',
        content:
        'Can you share any code you\'ve written so far?',
        isSentByMe: false,
        isRead: false,
        createdAt: DateTime.now()
            .subtract(const Duration(hours: 1)),
      ),
      unreadCount: 1,
      isOnline: true,
      updatedAt:
      DateTime.now().subtract(const Duration(hours: 1)),
    ),
    ConversationModel(
      id: 'conv_002',
      participantId: 'mtr_002',
      participantName: 'James Tarimo',
      participantAvatarUrl:
      'https://i.pravatar.cc/150?img=15',
      participantRole: 'mentor',
      lastMessage: MessageModel(
        id: 'msg_006',
        conversationId: 'conv_002',
        senderId: 'usr_001',
        content:
        'Thank you James! I opened a DSE account this morning. 🎉',
        isSentByMe: true,
        isRead: true,
        createdAt: DateTime.now()
            .subtract(const Duration(hours: 20)),
      ),
      unreadCount: 0,
      isOnline: false,
      updatedAt: DateTime.now()
          .subtract(const Duration(hours: 20)),
    ),
  ];
}