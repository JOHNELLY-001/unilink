import 'package:equatable/equatable.dart';

class AiMessageModel extends Equatable {
  final String id;
  final String content;
  final AiMessageRole role; // 'user' | 'assistant'
  final AiMessageType type;
  final List<AiActionCard>? actionCards;
  final List<AiSuggestionChip>? suggestions;
  final DateTime createdAt;
  final bool isLoading;

  const AiMessageModel({
    required this.id,
    required this.content,
    required this.role,
    this.type = AiMessageType.text,
    this.actionCards,
    this.suggestions,
    required this.createdAt,
    this.isLoading = false,
  });

  bool get isUser => role == AiMessageRole.user;
  bool get isAssistant => role == AiMessageRole.assistant;

  factory AiMessageModel.fromJson(Map<String, dynamic> json) {
    return AiMessageModel(
      id: json['id'] as String,
      content: json['content'] as String,
      role: AiMessageRole.values.firstWhere(
            (r) => r.name == json['role'],
        orElse: () => AiMessageRole.user,
      ),
      type: AiMessageType.values.firstWhere(
            (t) => t.name == json['type'],
        orElse: () => AiMessageType.text,
      ),
      actionCards: (json['action_cards'] as List<dynamic>?)
          ?.map((c) => AiActionCard.fromJson(c as Map<String, dynamic>))
          .toList(),
      suggestions: (json['suggestions'] as List<dynamic>?)
          ?.map((s) => AiSuggestionChip.fromJson(s as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      isLoading: json['is_loading'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'content': content, 'role': role.name,
    'type': type.name,
    'action_cards': actionCards?.map((c) => c.toJson()).toList(),
    'suggestions': suggestions?.map((s) => s.toJson()).toList(),
    'created_at': createdAt.toIso8601String(),
    'is_loading': isLoading,
  };

  // Factory for a loading/typing indicator message
  factory AiMessageModel.loading() => AiMessageModel(
    id: 'loading',
    content: '',
    role: AiMessageRole.assistant,
    isLoading: true,
    createdAt: DateTime.now(),
  );

  @override
  List<Object?> get props => [id, content, role, createdAt, isLoading];
}

enum AiMessageRole { user, assistant }

enum AiMessageType { text, careerGuide, mentorSuggestion, scholarshipSuggestion, roadmap }

class AiActionCard extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String actionType; // 'view_mentor'|'view_career'|'view_scholarship'
  final String actionTargetId;
  final String emoji;

  const AiActionCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.actionType,
    required this.actionTargetId,
    required this.emoji,
  });

  factory AiActionCard.fromJson(Map<String, dynamic> json) => AiActionCard(
    id: json['id'] as String,
    title: json['title'] as String,
    subtitle: json['subtitle'] as String,
    actionType: json['action_type'] as String,
    actionTargetId: json['action_target_id'] as String,
    emoji: json['emoji'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'subtitle': subtitle,
    'action_type': actionType, 'action_target_id': actionTargetId,
    'emoji': emoji,
  };

  @override
  List<Object?> get props => [id, title, actionType, actionTargetId];
}

class AiSuggestionChip extends Equatable {
  final String id;
  final String label;
  final String prompt;

  const AiSuggestionChip({
    required this.id,
    required this.label,
    required this.prompt,
  });

  factory AiSuggestionChip.fromJson(Map<String, dynamic> json) =>
      AiSuggestionChip(
        id: json['id'] as String,
        label: json['label'] as String,
        prompt: json['prompt'] as String,
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'label': label, 'prompt': prompt};

  @override
  List<Object?> get props => [id, label, prompt];
}