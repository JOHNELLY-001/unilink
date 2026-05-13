import 'dart:async';
import '../abstracts/message_repository.dart';
import '../../models/message_model.dart';

class MockMessageRepository implements MessageRepository {
  final Map<String, List<MessageModel>> _messages = _buildMockMessages();
  final List<ConversationModel> _conversations = _buildMockConversations();
  final _messageControllers = <String, StreamController<MessageModel>>{};

  @override
  Future<List<ConversationModel>> getConversations(String userId) async {
    await _delay();
    return List.from(_conversations)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<List<MessageModel>> getMessages({
    required String conversationId,
    int page = 1,
    int pageSize = 30,
  }) async {
    await _delay();
    final msgs = _messages[conversationId] ?? [];
    final start = (page - 1) * pageSize;
    if (start >= msgs.length) return [];
    final slice = msgs.sublist(start, (start + pageSize).clamp(0, msgs.length));
    return slice.reversed.toList(); // newest first
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
    String? mediaUrl,
  }) async {
    await _delay(400);
    final msg = MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: senderId,
      content: content,
      type: type,
      isSentByMe: true,
      mediaUrl: mediaUrl,
      createdAt: DateTime.now(),
    );
    _messages[conversationId] ??= [];
    _messages[conversationId]!.add(msg);
    _messageControllers[conversationId]?.add(msg);
    return msg;
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    await _delay(200);
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      // Mock: unread count reset (real impl updates DB)
    }
  }

  @override
  Future<ConversationModel> getOrCreateConversation({
    required String currentUserId,
    required String otherUserId,
  }) async {
    await _delay();
    try {
      return _conversations.firstWhere(
              (c) => c.participantId == otherUserId);
    } catch (_) {
      final newConv = ConversationModel(
        id: 'conv_${DateTime.now().millisecondsSinceEpoch}',
        participantId: otherUserId,
        participantName: 'New Conversation',
        participantRole: 'mentor',
        unreadCount: 0,
        updatedAt: DateTime.now(),
      );
      _conversations.add(newConv);
      return newConv;
    }
  }

  @override
  Future<int> getTotalUnreadCount(String userId) async {
    await _delay(200);
    return _conversations.fold<int>(0, (sum, c) => sum + c.unreadCount);
  }

  @override
  Stream<MessageModel> messageStream(String conversationId) {
    _messageControllers[conversationId] ??=
    StreamController<MessageModel>.broadcast();
    return _messageControllers[conversationId]!.stream;
  }

  @override
  Stream<List<ConversationModel>> conversationStream(String userId) {
    // Mock: returns a one-time stream of current conversations
    return Stream.value(List.from(_conversations));
  }

  Future<void> _delay([int ms = 600]) async =>
      Future.delayed(Duration(milliseconds: ms));

  static Map<String, List<MessageModel>> _buildMockMessages() => {
    'conv_001': [
      MessageModel(id: 'msg_001', conversationId: 'conv_001', senderId: 'mtr_001', content: 'Hi Amina! Looking forward to our session on Wednesday. Let me know if you have any questions before then.', isSentByMe: false, isRead: true, createdAt: DateTime.now().subtract(const Duration(hours: 5))),
      MessageModel(id: 'msg_002', conversationId: 'conv_001', senderId: 'usr_001', content: 'Thank you Grace! I\'ve been practicing Flutter and have a few questions about state management. See you then!', isSentByMe: true, isRead: true, createdAt: DateTime.now().subtract(const Duration(hours: 4))),
      MessageModel(id: 'msg_003', conversationId: 'conv_001', senderId: 'mtr_001', content: 'Perfect! We\'ll cover Riverpod in detail. It\'s the best approach for production Flutter apps.', isSentByMe: false, isRead: true, createdAt: DateTime.now().subtract(const Duration(hours: 3))),
      MessageModel(id: 'msg_004', conversationId: 'conv_001', senderId: 'mtr_001', content: 'Also, can you share any code you\'ve written so far? Would love to review before the session.', isSentByMe: false, isRead: false, createdAt: DateTime.now().subtract(const Duration(hours: 1))),
    ],
    'conv_002': [
      MessageModel(id: 'msg_005', conversationId: 'conv_002', senderId: 'mtr_002', content: 'Great session yesterday Amina! You asked really sharp questions about DSE. Keep it up.', isSentByMe: false, isRead: true, createdAt: DateTime.now().subtract(const Duration(days: 1))),
      MessageModel(id: 'msg_006', conversationId: 'conv_002', senderId: 'usr_001', content: 'Thank you James! I opened a DSE account this morning. First step taken! 🎉', isSentByMe: true, isRead: true, createdAt: DateTime.now().subtract(const Duration(hours: 20))),
    ],
  };

  static List<ConversationModel> _buildMockConversations() => [
    ConversationModel(
      id: 'conv_001',
      participantId: 'mtr_001',
      participantName: 'Grace Kimaro',
      participantAvatarUrl: 'https://i.pravatar.cc/150?img=23',
      participantRole: 'mentor',
      lastMessage: MessageModel(
        id: 'msg_004', conversationId: 'conv_001',
        senderId: 'mtr_001',
        content: 'Also, can you share any code you\'ve written so far?',
        isSentByMe: false, isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      unreadCount: 1,
      isOnline: true,
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    ConversationModel(
      id: 'conv_002',
      participantId: 'mtr_002',
      participantName: 'James Tarimo',
      participantAvatarUrl: 'https://i.pravatar.cc/150?img=15',
      participantRole: 'mentor',
      lastMessage: MessageModel(
        id: 'msg_006', conversationId: 'conv_002',
        senderId: 'usr_001',
        content: 'Thank you James! I opened a DSE account this morning. 🎉',
        isSentByMe: true, isRead: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 20)),
      ),
      unreadCount: 0,
      isOnline: false,
      updatedAt: DateTime.now().subtract(const Duration(hours: 20)),
    ),
  ];
}