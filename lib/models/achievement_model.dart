import 'package:equatable/equatable.dart';

class AchievementModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final AchievementRarity rarity;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int pointsAwarded;
  final double progressPercent;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.rarity,
    this.isUnlocked = false,
    this.unlockedAt,
    this.pointsAwarded = 10,
    this.progressPercent = 0.0,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) =>
      AchievementModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        emoji: json['emoji'] as String,
        rarity: AchievementRarity.values.firstWhere(
              (r) => r.name == json['rarity'],
          orElse: () => AchievementRarity.common,
        ),
        isUnlocked: json['is_unlocked'] as bool? ?? false,
        unlockedAt: json['unlocked_at'] != null
            ? DateTime.parse(json['unlocked_at'] as String)
            : null,
        pointsAwarded: json['points_awarded'] as int? ?? 10,
        progressPercent:
        (json['progress_percent'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'description': description,
    'emoji': emoji, 'rarity': rarity.name,
    'is_unlocked': isUnlocked,
    'unlocked_at': unlockedAt?.toIso8601String(),
    'points_awarded': pointsAwarded,
    'progress_percent': progressPercent,
  };

  @override
  List<Object?> get props => [id, title, isUnlocked, rarity];
}

enum AchievementRarity { common, rare, epic, legendary }