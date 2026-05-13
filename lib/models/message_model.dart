import 'package:equatable/equatable.dart';

class ConversationModel extends Equatable {
  final String id;
  final String participantId;
  final String participantName;
  final String? participantAvatarUrl;
  final String participantRole;
  final MessageModel? lastMessage;
  final int unreadCount;
  final bool isOnline;
  final DateTime updatedAt;

  const ConversationModel({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.participantAvatarUrl,
    required this.participantRole,
    this.lastMessage,
    this.unreadCount = 0,
    this.isOnline = false,
    required this.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      participantId: json['participant_id'] as String,
      participantName: json['participant_name'] as String,
      participantAvatarUrl: json['participant_avatar_url'] as String?,
      participantRole: json['participant_role'] as String,
      lastMessage: json['last_message'] != null
          ? MessageModel.fromJson(
          json['last_message'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      isOnline: json['is_online'] as bool? ?? false,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'participant_id': participantId,
    'participant_name': participantName,
    'participant_avatar_url': participantAvatarUrl,
    'participant_role': participantRole,
    'last_message': lastMessage?.toJson(),
    'unread_count': unreadCount, 'is_online': isOnline,
    'updated_at': updatedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, participantId, unreadCount, updatedAt];
}

class MessageModel extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final MessageType type;
  final bool isRead;
  final bool isSentByMe;
  final String? mediaUrl;
  final int? voiceDurationSeconds;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.type = MessageType.text,
    this.isRead = false,
    this.isSentByMe = false,
    this.mediaUrl,
    this.voiceDurationSeconds,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      type: MessageType.values.firstWhere(
            (t) => t.name == json['type'],
        orElse: () => MessageType.text,
      ),
      isRead: json['is_read'] as bool? ?? false,
      isSentByMe: json['is_sent_by_me'] as bool? ?? false,
      mediaUrl: json['media_url'] as String?,
      voiceDurationSeconds: json['voice_duration_seconds'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'conversation_id': conversationId,
    'sender_id': senderId, 'content': content,
    'type': type.name, 'is_read': isRead,
    'is_sent_by_me': isSentByMe, 'media_url': mediaUrl,
    'voice_duration_seconds': voiceDurationSeconds,
    'created_at': createdAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, senderId, content, createdAt];
}

enum MessageType { text, image, voice, file, sessionRequest }