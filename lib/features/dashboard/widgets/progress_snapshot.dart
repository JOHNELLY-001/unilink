import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_spacing.dart';
import '../../../providers/progress_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/loaders/shimmer_loader.dart';

class ProgressSnapshot extends ConsumerWidget {
  const ProgressSnapshot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userProgressProvider);
    final goalsState = ref.watch(goalsProvider);

    return progressAsync.when(
      loading: () => const ShimmerLoader(
          width: double.infinity, height: 140, borderRadius: 18),
      error: (_, __) => const SizedBox.shrink(),
      data: (progress) {
        return GestureDetector(
          onTap: () => context.push(AppRoutes.progress),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryNavy.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Your Progress',
                        style: AppTypography.h4),
                    Text(
                      'Level ${progress.currentLevel}',
                      style: AppTypography.labelM.copyWith(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // XP progress bar
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${progress.totalPoints} XP',
                                style: AppTypography.labelM,
                              ),
                              Text(
                                '${progress.pointsToNextLevel} to Level ${progress.currentLevel + 1}',
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress.totalPoints /
                                  (progress.totalPoints +
                                      progress.pointsToNextLevel),
                              backgroundColor: AppColors.borderLight,
                              valueColor: const AlwaysStoppedAnimation(
                                  AppColors.primaryBlue),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Active goals
                if (goalsState.isNotEmpty) ...[
                  Text('Active Goals',
                      style: AppTypography.caption.copyWith(
                          color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  ...goalsState.take(2).map((goal) =>
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _GoalRow(goal: goal),
                      )),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GoalRow extends StatelessWidget {
  final dynamic goal;

  const _GoalRow({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            goal.title,
            style: AppTypography.labelS.copyWith(
                color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        LinearPercentIndicator(
          width: 80,
          lineHeight: 5,
          percent: (goal.progressPercent / 100).clamp(0.0, 1.0),
          progressColor: AppColors.primaryBlue,
          backgroundColor: AppColors.borderLight,
          barRadius: const Radius.circular(4),
          padding: EdgeInsets.zero,
        ),
        const SizedBox(width: 6),
        Text(
          '${goal.progressPercent.toInt()}%',
          style: AppTypography.caption.copyWith(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}