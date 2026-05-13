import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_gradients.dart';
import '../../../theme/app_spacing.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/career_provider.dart';
import '../../../providers/mentor_provider.dart';
import '../../../providers/opportunity_provider.dart';
import '../../../providers/progress_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/loaders/shimmer_loader.dart';
import '../../../shared/widgets/cards/stat_card.dart';
import '../../../shared/widgets/badges/tag_chip.dart';
import '../../careers/widgets/career_card.dart';
import '../../mentors/widgets/mentor_card.dart';
import '../../opportunities/widgets/opportunity_card.dart';
import '../widgets/welcome_hero.dart';
import '../widgets/quick_actions_bar.dart';
import '../widgets/progress_snapshot.dart';

class StudentDashboard extends ConsumerStatefulWidget {
  const StudentDashboard({super.key});

  @override
  ConsumerState<StudentDashboard> createState() =>
      _StudentDashboardState();
}

class _StudentDashboardState extends ConsumerState<StudentDashboard> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: RefreshIndicator(
        color: AppColors.primaryBlue,
        onRefresh: () async {
          ref.invalidate(recommendedCareersProvider);
          ref.invalidate(recommendedMentorsProvider);
          ref.invalidate(recommendedOpportunitiesProvider);
          ref.invalidate(userProgressProvider);
          await Future.delayed(const Duration(milliseconds: 800));
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ─── Welcome Hero ──────────────────────────────────────
            SliverToBoxAdapter(
              child: WelcomeHero(
                user: user,
                onDrawerTap: () => Scaffold.of(context).openDrawer(),
                onNotificationTap: () {},
                onAiTap: () => context.push(AppRoutes.aiAssistant),
              ),
            ),

            // ─── Quick Actions ─────────────────────────────────────
            SliverToBoxAdapter(
              child: QuickActionsBar(
                onCareersTap: () => context.go(AppRoutes.careers),
                onMentorsTap: () => context.go(AppRoutes.mentors),
                onOpportunitiesTap: () =>
                    context.push(AppRoutes.opportunities),
                onAiTap: () => context.go(AppRoutes.aiAssistant),
              ).animate().fadeIn(delay: 200.ms),
            ),

            // ─── Progress snapshot ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding, 24,
                    AppSpacing.screenPadding, 0),
                child: ProgressSnapshot()
                    .animate()
                    .fadeIn(delay: 300.ms),
              ),
            ),

            // ─── Stats row ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: _StatsRow()
                  .animate()
                  .fadeIn(delay: 350.ms),
            ),

            // ─── Upcoming session ──────────────────────────────────
            SliverToBoxAdapter(
              child: _UpcomingSessionCard()
                  .animate()
                  .fadeIn(delay: 400.ms),
            ),

            // ─── Deadline soon ─────────────────────────────────────
            SliverToBoxAdapter(
              child: _DeadlineSoonSection()
                  .animate()
                  .fadeIn(delay: 450.ms),
            ),

            // ─── AI recommendation banner ──────────────────────────
            SliverToBoxAdapter(
              child: _AiBannerCard()
                  .animate()
                  .fadeIn(delay: 500.ms),
            ),

            // ─── Recommended careers ───────────────────────────────
            SliverToBoxAdapter(
              child: _RecommendedCareers()
                  .animate()
                  .fadeIn(delay: 550.ms),
            ),

            // ─── Recommended mentors ───────────────────────────────
            SliverToBoxAdapter(
              child: _RecommendedMentors()
                  .animate()
                  .fadeIn(delay: 600.ms),
            ),

            // ─── Bottom padding ────────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).padding.bottom + 100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────

class _StatsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userProgressProvider);
    final streakAsync = ref.watch(streakProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 20, AppSpacing.screenPadding, 0),
      child: Row(
        children: [
          Expanded(
            child: progressAsync.when(
              loading: () => const ShimmerLoader(
                  width: double.infinity, height: 100, borderRadius: 14),
              error: (_, __) => const SizedBox.shrink(),
              data: (p) => StatCard(
                value: '${p.sessionsCompleted}',
                label: 'Sessions Done',
                icon: Icons.calendar_month_rounded,
                color: AppColors.primaryBlue,
                onTap: () => context.push(AppRoutes.progress),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: streakAsync.when(
              loading: () => const ShimmerLoader(
                  width: double.infinity, height: 100, borderRadius: 14),
              error: (_, __) => const SizedBox.shrink(),
              data: (s) => StatCard(
                value: '${s.currentStreak}🔥',
                label: 'Day Streak',
                icon: Icons.local_fire_department_rounded,
                color: AppColors.warning,
                onTap: () => context.push(AppRoutes.progress),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: progressAsync.when(
              loading: () => const ShimmerLoader(
                  width: double.infinity, height: 100, borderRadius: 14),
              error: (_, __) => const SizedBox.shrink(),
              data: (p) => StatCard(
                value: '${p.careersExplored}',
                label: 'Careers Explored',
                icon: Icons.explore_rounded,
                color: AppColors.accentTeal,
                onTap: () => context.go(AppRoutes.careers),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Upcoming Session Card ────────────────────────────────────────────────

class _UpcomingSessionCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(upcomingSessionsProvider);

    return sessionsAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding, 24, AppSpacing.screenPadding, 0),
        child: const ShimmerLoader(
            width: double.infinity, height: 110, borderRadius: 16),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (sessions) {
        if (sessions.isEmpty) return const SizedBox.shrink();
        final session = sessions.first;

        return Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding, 24,
              AppSpacing.screenPadding, 0),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppGradients.heroBlue,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // Calendar icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${session.scheduledAt.day}',
                        style: AppTypography.h2
                            .copyWith(color: AppColors.white, height: 1),
                      ),
                      Text(
                        _monthShort(session.scheduledAt.month),
                        style: AppTypography.caption
                            .copyWith(color: AppColors.white.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upcoming Session',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        session.topic,
                        style: AppTypography.h4
                            .copyWith(color: AppColors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'with ${session.mentorName} • ${session.durationMinutes}min',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Join',
                    style: AppTypography.labelM.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _monthShort(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }
}

// ─── Deadline Soon Section ────────────────────────────────────────────────

class _DeadlineSoonSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deadlineAsync = ref.watch(deadlineSoonOpportunitiesProvider);

    return deadlineAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (opps) {
        if (opps.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: SectionHeader(
                title: '⏰ Closing Soon',
                actionLabel: 'View all',
                onActionTap: () =>
                    context.push(AppRoutes.opportunities),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding),
                itemCount: opps.length,
                separatorBuilder: (_, __) =>
                const SizedBox(width: 12),
                itemBuilder: (context, index) =>
                    _DeadlineCard(opportunity: opps[index])
                        .animate()
                        .fadeIn(
                      delay: Duration(
                          milliseconds: 60 * index),
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DeadlineCard extends StatelessWidget {
  final dynamic opportunity;

  const _DeadlineCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final daysLeft = opportunity.daysUntilDeadline as int;
    final isUrgent = daysLeft <= 3;

    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUrgent ? AppColors.errorLight : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUrgent
              ? AppColors.error.withOpacity(0.3)
              : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                opportunity.type.emoji,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isUrgent ? AppColors.error : AppColors.warning,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$daysLeft day${daysLeft != 1 ? 's' : ''} left',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            opportunity.title,
            style: AppTypography.labelL,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            opportunity.organization,
            style: AppTypography.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── AI Banner Card ───────────────────────────────────────────────────────

class _AiBannerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 28,
          AppSpacing.screenPadding, 0),
      child: GestureDetector(
        onTap: () => context.go(AppRoutes.aiAssistant),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // AI icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.accentTeal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.smart_toy_rounded,
                    color: Colors.white, size: 28),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.05, 1.05),
                duration: 2000.ms,
                curve: Curves.easeInOut,
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'UniLink AI',
                          style: AppTypography.h3.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: AppGradients.premium,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'BETA',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ask me anything about your career, universities, or scholarships.',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.white.withOpacity(0.65),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Recommended Careers ──────────────────────────────────────────────────

class _RecommendedCareers extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final careersAsync = ref.watch(recommendedCareersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding),
          child: SectionHeader(
            title: '💡 Recommended for You',
            actionLabel: 'See all',
            onActionTap: () => context.go(AppRoutes.careers),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 200,
          child: careersAsync.when(
            loading: () => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              itemCount: 3,
              separatorBuilder: (_, __) =>
              const SizedBox(width: 12),
              itemBuilder: (_, __) => const ShimmerLoader(
                  width: 160, height: 200, borderRadius: 16),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (careers) => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              itemCount: careers.length,
              separatorBuilder: (_, __) =>
              const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  CompactCareerCard(
                    career: careers[index],
                    onTap: () => context.push(
                        AppRoutes.careerDetailPath(careers[index].id)),
                  )
                      .animate()
                      .fadeIn(
                    delay: Duration(
                        milliseconds: 60 * index),
                    duration: 400.ms,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Recommended Mentors ──────────────────────────────────────────────────

class _RecommendedMentors extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mentorsAsync = ref.watch(recommendedMentorsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding),
          child: SectionHeader(
            title: '🤝 Mentors for You',
            actionLabel: 'Browse all',
            onActionTap: () => context.go(AppRoutes.mentors),
          ),
        ),
        const SizedBox(height: 14),
        mentorsAsync.when(
          loading: () => Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            child: const ShimmerList(
                itemCount: 2,
                itemBuilder: MentorCardSkeleton.new),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (mentors) => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            itemCount: mentors.length,
            separatorBuilder: (_, __) =>
            const SizedBox(height: 10),
            itemBuilder: (context, index) => MentorListCard(
              mentor: mentors[index],
              onTap: () => context.push(
                  AppRoutes.mentorDetailPath(mentors[index].id)),
            )
                .animate()
                .fadeIn(
              delay: Duration(milliseconds: 80 * index),
              duration: 400.ms,
            ),
          ),
        ),
      ],
    );
  }
}