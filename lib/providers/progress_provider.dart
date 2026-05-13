import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement_model.dart';
import '../repositories/abstracts/progress_repository.dart';
import 'repository_providers.dart';
import 'auth_provider.dart';

final userProgressProvider = FutureProvider<UserProgressModel>((ref) async {
  final repo = ref.read(progressRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return const UserProgressModel(
      totalPoints: 0, currentLevel: 1, pointsToNextLevel: 100,
      sessionsCompleted: 0, careersExplored: 0, resourcesCompleted: 0,
      opportunitiesApplied: 0, profileCompletionPercent: 0,
    );
  }
  return repo.getUserProgress(user.id);
});

final achievementsProvider =
FutureProvider<List<AchievementModel>>((ref) async {
  final repo = ref.read(progressRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return repo.getAchievements(user.id);
});

final streakProvider = FutureProvider<StreakModel>((ref) async {
  final repo = ref.read(progressRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return const StreakModel(currentStreak: 0, longestStreak: 0);
  }
  return repo.getStreak(user.id);
});

final goalsProvider = StateProvider<List<GoalModel>>((ref) => [
  GoalModel(
    id: 'goal_001',
    title: 'Submit UDSM Application',
    progressPercent: 45,
    targetDate: DateTime.now().add(const Duration(days: 30)),
  ),
  GoalModel(
    id: 'goal_002',
    title: 'Learn Python Basics',
    progressPercent: 70,
    targetDate: DateTime.now().add(const Duration(days: 14)),
  ),
  GoalModel(
    id: 'goal_003',
    title: 'Book 3 Mentor Sessions',
    progressPercent: 33,
    targetDate: DateTime.now().add(const Duration(days: 60)),
  ),
]);