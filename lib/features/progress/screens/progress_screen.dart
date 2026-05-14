import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_gradients.dart';
import '../../../providers/progress_provider.dart';
import '../../../models/achievement_model.dart';
import '../../../shared/widgets/loaders/shimmer_loader.dart';
import '../../../shared/widgets/section_header.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userProgressProvider);
    final streakAsync = ref.watch(streakProvider);
    final achievementsAsync = ref.watch(achievementsProvider);
    final goals = ref.watch(goalsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // ─── App bar ────────────────────────────────────
          SliverAppBar(
            backgroundColor: AppColors.primaryNavy,
            pinned: true,
            automaticallyImplyLeading: false,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: _ProgressHero(
                progressAsync: progressAsync,
                streakAsync: streakAsync,
              ),
            ),
            title: const Text(
              'My Progress',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),

          // ─── Streak section ─────────────────────────────
          SliverToBoxAdapter(
            child: streakAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.screenPadding),
                child: ShimmerLoader(
                    width: double.infinity,
                    height: 100,
                    borderRadius: 16),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (streak) => _StreakSection(streak: streak)
                  .animate()
                  .fadeIn(delay: 100.ms),
            ),
          ),

          // ─── Goals section ──────────────────────────────
          SliverToBoxAdapter(
            child: _GoalsSection(goals: goals)
                .animate()
                .fadeIn(delay: 200.ms),
          ),

          // ─── Stats grid ─────────────────────────────────
          SliverToBoxAdapter(
            child: progressAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.screenPadding),
                child: ShimmerLoader(
                    width: double.infinity,
                    height: 160,
                    borderRadius: 16),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (p) => _StatsGrid(progress: p)
                  .animate()
                  .fadeIn(delay: 300.ms),
            ),
          ),

          // ─── Achievements ───────────────────────────────
          SliverToBoxAdapter(
            child: achievementsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.screenPadding),
                child: ShimmerList(itemCount: 3, itemHeight: 80),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (achievements) =>
                  _AchievementsSection(achievements: achievements)
                      .animate()
                      .fadeIn(delay: 400.ms),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
                height: MediaQuery.of(context).padding.bottom + 80),
          ),
        ],
      ),
    );
  }
}

// ─── Progress hero ────────────────────────────────────────────────────────

class _ProgressHero extends StatelessWidget {
  final AsyncValue<dynamic> progressAsync;
  final AsyncValue<dynamic> streakAsync;

  const _ProgressHero({
    required this.progressAsync,
    required this.streakAsync,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.heroNavy,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
          child: progressAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(
                  valueColor:
                  AlwaysStoppedAnimation(AppColors.white)),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (progress) => Row(
              children: [
                // Level ring
                CircularPercentIndicator(
                  radius: 50,
                  lineWidth: 6,
                  percent: (progress.totalPoints /
                      (progress.totalPoints +
                          progress.pointsToNextLevel))
                      .clamp(0.0, 1.0),
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Lv.${progress.currentLevel}',
                        style: AppTypography.h3.copyWith(
                          color: AppColors.white,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${progress.totalPoints}xp',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.white.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  progressColor: AppColors.accentTealLight,
                  backgroundColor:
                  Colors.white.withOpacity(0.15),
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                const SizedBox(width: 20),

                // Stats
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Level ${progress.currentLevel}',
                        style: AppTypography.h2.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${progress.pointsToNextLevel} XP to Level ${progress.currentLevel + 1}',
                        style: AppTypography.bodyS.copyWith(
                          color: AppColors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (progress.totalPoints /
                              (progress.totalPoints +
                                  progress.pointsToNextLevel))
                              .clamp(0.0, 1.0),
                          backgroundColor:
                          Colors.white.withOpacity(0.15),
                          valueColor:
                          const AlwaysStoppedAnimation(
                              AppColors.accentTealLight),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Streak section ───────────────────────────────────────────────────────

class _StreakSection extends StatelessWidget {
  final dynamic streak;

  const _StreakSection({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 20,
          AppSpacing.screenPadding, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF7ED), Color(0xFFFEF3C7)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: AppColors.warning.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            // Flame
            Column(
              children: [
                const Text('🔥',
                    style: TextStyle(fontSize: 40)),
                Text(
                  '${streak.currentStreak}',
                  style: AppTypography.displayM.copyWith(
                    color: AppColors.warning,
                    height: 1,
                  ),
                ),
                Text(
                  'day streak',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    streak.isActiveToday
                        ? '🎉 You\'re on a streak!'
                        : '⚠️ Log in daily to keep your streak',
                    style: AppTypography.h4,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Longest streak: ${streak.longestStreak} days',
                    style: AppTypography.bodyS,
                  ),
                  const SizedBox(height: 12),

                  // Mini calendar — last 7 days
                  Row(
                    children: List.generate(7, (i) {
                      final day = DateTime.now()
                          .subtract(Duration(days: 6 - i));
                      final isActive = streak.activeDates
                          .any((d) =>
                      d.year == day.year &&
                          d.month == day.month &&
                          d.day == day.day);
                      const days = [
                        'M','T','W','T','F','S','S'
                      ];
                      return Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.warning
                                    : AppColors.border,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: isActive
                                    ? const Text('🔥',
                                    style: TextStyle(
                                        fontSize: 12))
                                    : Text(
                                  days[day.weekday - 1],
                                  style: AppTypography
                                      .caption
                                      .copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Goals section ────────────────────────────────────────────────────────

class _GoalsSection extends StatelessWidget {
  final List<dynamic> goals;

  const _GoalsSection({required this.goals});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 24,
          AppSpacing.screenPadding, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: '🎯 Active Goals'),
          const SizedBox(height: 14),
          ...goals.asMap().entries.map((e) {
            final goal = e.value;
            final daysLeft = goal.targetDate
                .difference(DateTime.now())
                .inDays;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border:
                  Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            goal.title,
                            style: AppTypography.labelL,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: daysLeft <= 7
                                ? AppColors.warningLight
                                : AppColors.infoLight,
                            borderRadius:
                            BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$daysLeft days left',
                            style: AppTypography.caption.copyWith(
                              color: daysLeft <= 7
                                  ? AppColors.warning
                                  : AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius:
                            BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (goal.progressPercent / 100)
                                  .clamp(0.0, 1.0),
                              backgroundColor:
                              AppColors.borderLight,
                              valueColor:
                              const AlwaysStoppedAnimation(
                                  AppColors.primaryBlue),
                              minHeight: 7,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${goal.progressPercent.toInt()}%',
                          style: AppTypography.labelM.copyWith(
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(
                delay: Duration(milliseconds: 80 * e.key),
                duration: 400.ms,
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Stats grid ───────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final dynamic progress;

  const _StatsGrid({required this.progress});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatItem('💬', 'Sessions\nCompleted',
          '${progress.sessionsCompleted}', AppColors.primaryBlue),
      _StatItem('🗺️', 'Careers\nExplored',
          '${progress.careersExplored}', AppColors.accentTeal),
      _StatItem('📚', 'Resources\nCompleted',
          '${progress.resourcesCompleted}', AppColors.premiumGold),
      _StatItem('📋', 'Opportunities\nApplied',
          '${progress.opportunitiesApplied}',
          AppColors.premiumPurple),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 24,
          AppSpacing.screenPadding, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: '📊 Activity Stats'),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.6,
            children: stats.asMap().entries.map((e) {
              final stat = e.value;
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border:
                  Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Text(stat.emoji,
                        style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Text(
                            stat.value,
                            style: AppTypography.h2.copyWith(
                              color: stat.color,
                            ),
                          ),
                          Text(
                            stat.label,
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(
                delay: Duration(
                    milliseconds: 60 * e.key),
                duration: 400.ms,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _StatItem(
      this.emoji, this.label, this.value, this.color);
}

// ─── Achievements section ─────────────────────────────────────────────────

class _AchievementsSection extends StatelessWidget {
  final List<AchievementModel> achievements;

  const _AchievementsSection({required this.achievements});

  @override
  Widget build(BuildContext context) {
    final unlocked =
    achievements.where((a) => a.isUnlocked).toList();
    final locked =
    achievements.where((a) => !a.isUnlocked).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 24,
          AppSpacing.screenPadding, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: '🏆 Achievements',
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${unlocked.length}/${achievements.length}',
                style: AppTypography.labelS.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Unlocked achievements
          if (unlocked.isNotEmpty) ...[
            Text('Unlocked', style: AppTypography.labelM
                .copyWith(color: AppColors.success)),
            const SizedBox(height: 8),
            ...unlocked.asMap().entries.map((e) =>
                _AchievementTile(
                  achievement: e.value,
                  isUnlocked: true,
                )
                    .animate()
                    .fadeIn(
                  delay: Duration(milliseconds: 60 * e.key),
                  duration: 400.ms,
                ),
            ),
            const SizedBox(height: 16),
          ],

          // Locked achievements
          if (locked.isNotEmpty) ...[
            Text('In Progress',
                style: AppTypography.labelM
                    .copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            ...locked.asMap().entries.map((e) =>
                _AchievementTile(
                  achievement: e.value,
                  isUnlocked: false,
                )
                    .animate()
                    .fadeIn(
                  delay: Duration(
                      milliseconds: 60 * (e.key + unlocked.length)),
                  duration: 400.ms,
                ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final AchievementModel achievement;
  final bool isUnlocked;

  const _AchievementTile({
    required this.achievement,
    required this.isUnlocked,
  });

  Color get _rarityColor {
    switch (achievement.rarity) {
      case AchievementRarity.common:
        return AppColors.textMuted;
      case AchievementRarity.rare:
        return AppColors.primaryBlue;
      case AchievementRarity.epic:
        return AppColors.premiumPurple;
      case AchievementRarity.legendary:
        return AppColors.premiumGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnlocked ? AppColors.white : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnlocked
              ? _rarityColor.withOpacity(0.3)
              : AppColors.borderLight,
          width: isUnlocked ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? _rarityColor.withOpacity(0.1)
                  : AppColors.borderLight,
              borderRadius: BorderRadius.circular(12),
              border: isUnlocked
                  ? Border.all(
                  color: _rarityColor.withOpacity(0.3))
                  : null,
            ),
            child: Center(
              child: Text(
                achievement.emoji,
                style: TextStyle(
                  fontSize: 22,
                  color: isUnlocked ? null : const Color(0x80000000),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: AppTypography.labelL.copyWith(
                          color: isUnlocked
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                    // Rarity tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: _rarityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        achievement.rarity.name.toUpperCase(),
                        style: AppTypography.caption.copyWith(
                          color: _rarityColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: AppTypography.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isUnlocked &&
                    achievement.progressPercent > 0) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: achievement.progressPercent / 100,
                      backgroundColor: AppColors.borderLight,
                      valueColor: AlwaysStoppedAnimation(
                          _rarityColor),
                      minHeight: 4,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 10),
          // XP badge
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? AppColors.successLight
                      : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${achievement.pointsAwarded}xp',
                  style: AppTypography.caption.copyWith(
                    color: isUnlocked
                        ? AppColors.success
                        : AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isUnlocked) ...[
                const SizedBox(height: 4),
                const Icon(Icons.check_circle_rounded,
                    size: 16, color: AppColors.success),
              ],
            ],
          ),
        ],
      ),
    );
  }
}