import '../abstracts/progress_repository.dart';
import '../../models/achievement_model.dart';

class MockProgressRepository implements ProgressRepository {
  @override
  Future<UserProgressModel> getUserProgress(String userId) async {
    await _delay();
    return const UserProgressModel(
      totalPoints: 340,
      currentLevel: 4,
      pointsToNextLevel: 160,
      sessionsCompleted: 2,
      careersExplored: 7,
      resourcesCompleted: 3,
      opportunitiesApplied: 1,
      profileCompletionPercent: 65.0,
    );
  }

  @override
  Future<List<AchievementModel>> getAchievements(String userId) async {
    await _delay();
    return _buildAchievements();
  }

  @override
  Future<List<AchievementModel>> getUnlockedAchievements(String userId) async {
    await _delay();
    return _buildAchievements().where((a) => a.isUnlocked).toList();
  }

  @override
  Future<void> updateGoalProgress({
    required String userId,
    required String goalId,
    required double progressPercent,
  }) async {
    await _delay(300);
  }

  @override
  Future<GoalModel> addGoal({
    required String userId,
    required String title,
    required DateTime targetDate,
  }) async {
    await _delay(500);
    return GoalModel(
      id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      progressPercent: 0.0,
      targetDate: targetDate,
    );
  }

  @override
  Future<void> completeGoal({
    required String userId,
    required String goalId,
  }) async {
    await _delay(400);
  }

  @override
  Future<void> recordDailyActivity(String userId) async {
    await _delay(200);
  }

  @override
  Future<StreakModel> getStreak(String userId) async {
    await _delay();
    return StreakModel(
      currentStreak: 7,
      longestStreak: 14,
      lastActiveDate: DateTime.now(),
      activeDates: List.generate(
        14,
            (i) => DateTime.now().subtract(Duration(days: i)),
      ),
    );
  }

  Future<void> _delay([int ms = 600]) async =>
      Future.delayed(Duration(milliseconds: ms));

  static List<AchievementModel> _buildAchievements() => [
    AchievementModel(
      id: 'ach_001',
      title: 'First Step',
      description: 'Completed your profile setup',
      emoji: '👣',
      rarity: AchievementRarity.common,
      isUnlocked: true,
      unlockedAt: DateTime(2024, 9, 2),
      pointsAwarded: 10,
      progressPercent: 100,
    ),
    AchievementModel(
      id: 'ach_002',
      title: 'Career Explorer',
      description: 'Explored 5 different career paths',
      emoji: '🗺️',
      rarity: AchievementRarity.common,
      isUnlocked: true,
      unlockedAt: DateTime(2024, 9, 15),
      pointsAwarded: 20,
      progressPercent: 100,
    ),
    AchievementModel(
      id: 'ach_003',
      title: 'Connected',
      description: 'Booked your first mentorship session',
      emoji: '🤝',
      rarity: AchievementRarity.rare,
      isUnlocked: true,
      unlockedAt: DateTime(2024, 10, 5),
      pointsAwarded: 50,
      progressPercent: 100,
    ),
    AchievementModel(
      id: 'ach_004',
      title: 'Week Warrior',
      description: 'Maintained a 7-day activity streak',
      emoji: '🔥',
      rarity: AchievementRarity.rare,
      isUnlocked: true,
      unlockedAt: DateTime.now(),
      pointsAwarded: 75,
      progressPercent: 100,
    ),
    AchievementModel(
      id: 'ach_005',
      title: 'Scholar Hunter',
      description: 'Applied to your first scholarship',
      emoji: '🎓',
      rarity: AchievementRarity.rare,
      isUnlocked: false,
      pointsAwarded: 50,
      progressPercent: 0,
    ),
    AchievementModel(
      id: 'ach_006',
      title: 'AI Whisperer',
      description: 'Had 20 conversations with UniLink AI',
      emoji: '🤖',
      rarity: AchievementRarity.epic,
      isUnlocked: false,
      pointsAwarded: 100,
      progressPercent: 35,
    ),
    AchievementModel(
      id: 'ach_007',
      title: 'Community Pillar',
      description: 'Received 100 reactions on your posts',
      emoji: '🌟',
      rarity: AchievementRarity.epic,
      isUnlocked: false,
      pointsAwarded: 150,
      progressPercent: 12,
    ),
    AchievementModel(
      id: 'ach_008',
      title: 'UniLink Legend',
      description: 'Complete all achievements and reach Level 10',
      emoji: '👑',
      rarity: AchievementRarity.legendary,
      isUnlocked: false,
      pointsAwarded: 500,
      progressPercent: 8,
    ),
  ];
}