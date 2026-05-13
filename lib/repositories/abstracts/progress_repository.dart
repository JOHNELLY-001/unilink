import '../../models/achievement_model.dart';

abstract class ProgressRepository {
  /// Fetch the user's overall progress summary.
  Future<UserProgressModel> getUserProgress(String userId);

  /// Fetch all achievements (locked and unlocked).
  Future<List<AchievementModel>> getAchievements(String userId);

  /// Fetch only unlocked achievements.
  Future<List<AchievementModel>> getUnlockedAchievements(String userId);

  /// Update goal completion percentage.
  Future<void> updateGoalProgress({
    required String userId,
    required String goalId,
    required double progressPercent,
  });

  /// Add a new learning goal.
  Future<GoalModel> addGoal({
    required String userId,
    required String title,
    required DateTime targetDate,
  });

  /// Mark a goal as complete.
  Future<void> completeGoal({
    required String userId,
    required String goalId,
  });

  /// Record a daily activity (triggers streak logic).
  Future<void> recordDailyActivity(String userId);

  /// Fetch current streak data.
  Future<StreakModel> getStreak(String userId);
}

// ─── Supporting Models (progress-specific, lightweight) ──────────────────────

class UserProgressModel {
  final int totalPoints;
  final int currentLevel;
  final int pointsToNextLevel;
  final int sessionsCompleted;
  final int careersExplored;
  final int resourcesCompleted;
  final int opportunitiesApplied;
  final double profileCompletionPercent;

  const UserProgressModel({
    required this.totalPoints,
    required this.currentLevel,
    required this.pointsToNextLevel,
    required this.sessionsCompleted,
    required this.careersExplored,
    required this.resourcesCompleted,
    required this.opportunitiesApplied,
    required this.profileCompletionPercent,
  });

  factory UserProgressModel.fromJson(Map<String, dynamic> json) =>
      UserProgressModel(
        totalPoints: json['total_points'] as int? ?? 0,
        currentLevel: json['current_level'] as int? ?? 1,
        pointsToNextLevel: json['points_to_next_level'] as int? ?? 100,
        sessionsCompleted: json['sessions_completed'] as int? ?? 0,
        careersExplored: json['careers_explored'] as int? ?? 0,
        resourcesCompleted: json['resources_completed'] as int? ?? 0,
        opportunitiesApplied: json['opportunities_applied'] as int? ?? 0,
        profileCompletionPercent:
        (json['profile_completion_percent'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
    'total_points': totalPoints,
    'current_level': currentLevel,
    'points_to_next_level': pointsToNextLevel,
    'sessions_completed': sessionsCompleted,
    'careers_explored': careersExplored,
    'resources_completed': resourcesCompleted,
    'opportunities_applied': opportunitiesApplied,
    'profile_completion_percent': profileCompletionPercent,
  };
}

class GoalModel {
  final String id;
  final String title;
  final double progressPercent;
  final DateTime targetDate;
  final bool isCompleted;

  const GoalModel({
    required this.id,
    required this.title,
    required this.progressPercent,
    required this.targetDate,
    this.isCompleted = false,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) => GoalModel(
    id: json['id'] as String,
    title: json['title'] as String,
    progressPercent:
    (json['progress_percent'] as num?)?.toDouble() ?? 0.0,
    targetDate: DateTime.parse(json['target_date'] as String),
    isCompleted: json['is_completed'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'progress_percent': progressPercent,
    'target_date': targetDate.toIso8601String(),
    'is_completed': isCompleted,
  };
}

class StreakModel {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;
  final List<DateTime> activeDates;

  const StreakModel({
    required this.currentStreak,
    required this.longestStreak,
    this.lastActiveDate,
    this.activeDates = const [],
  });

  bool get isActiveToday {
    if (lastActiveDate == null) return false;
    final now = DateTime.now();
    return lastActiveDate!.year == now.year &&
        lastActiveDate!.month == now.month &&
        lastActiveDate!.day == now.day;
  }

  factory StreakModel.fromJson(Map<String, dynamic> json) => StreakModel(
    currentStreak: json['current_streak'] as int? ?? 0,
    longestStreak: json['longest_streak'] as int? ?? 0,
    lastActiveDate: json['last_active_date'] != null
        ? DateTime.parse(json['last_active_date'] as String)
        : null,
    activeDates: (json['active_dates'] as List<dynamic>? ?? [])
        .map((d) => DateTime.parse(d as String))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'current_streak': currentStreak,
    'longest_streak': longestStreak,
    'last_active_date': lastActiveDate?.toIso8601String(),
    'active_dates': activeDates.map((d) => d.toIso8601String()).toList(),
  };
}