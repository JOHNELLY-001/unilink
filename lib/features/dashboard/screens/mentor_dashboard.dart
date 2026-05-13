import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_gradients.dart';
import '../../../theme/app_spacing.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/mentor_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/cards/stat_card.dart';
import '../../../shared/widgets/loaders/shimmer_loader.dart';
import '../../../shared/widgets/badges/tag_chip.dart';

class MentorDashboard extends ConsumerWidget {
  const MentorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final sessionsAsync = ref.watch(mySessionsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: RefreshIndicator(
        color: AppColors.primaryBlue,
        onRefresh: () async {
          ref.invalidate(mySessionsProvider);
          await Future.delayed(const Duration(milliseconds: 800));
        },
        child: CustomScrollView(
          slivers: [
            // ─── Mentor Hero ──────────────────────────────────────
            SliverToBoxAdapter(
              child: _MentorHero(user: user),
            ),

            // ─── Approval status ──────────────────────────────────
            SliverToBoxAdapter(
              child: _ApprovalStatusCard()
                  .animate()
                  .fadeIn(delay: 200.ms),
            ),

            // ─── Stats ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _MentorStatsRow()
                  .animate()
                  .fadeIn(delay: 300.ms),
            ),

            // ─── Upcoming sessions ────────────────────────────────
            SliverToBoxAdapter(
              child: _UpcomingSessionsList()
                  .animate()
                  .fadeIn(delay: 400.ms),
            ),

            // ─── Quick actions ────────────────────────────────────
            SliverToBoxAdapter(
              child: _MentorQuickActions()
                  .animate()
                  .fadeIn(delay: 500.ms),
            ),

            // ─── Impact summary ───────────────────────────────────
            SliverToBoxAdapter(
              child: _ImpactSummary()
                  .animate()
                  .fadeIn(delay: 600.ms),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                  height: MediaQuery.of(context).padding.bottom + 100),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mentor Hero ──────────────────────────────────────────────────────────

class _MentorHero extends StatelessWidget {
  final dynamic user;

  const _MentorHero({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        28,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D4F3C), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: AvatarWidget(
                  imageUrl: user?.avatarUrl,
                  name: user?.fullName ?? 'Mentor',
                  size: 42,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Available',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_outlined,
                          color: AppColors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 22),

          Text(
            'Welcome back,',
            style: AppTypography.bodyL
                .copyWith(color: AppColors.white.withOpacity(0.7)),
          ).animate().fadeIn(delay: 150.ms),

          Text(
            '${user?.firstName ?? 'Mentor'} 👋',
            style: AppTypography.displayM
                .copyWith(color: AppColors.white, height: 1.2),
          )
              .animate()
              .fadeIn(delay: 200.ms)
              .slideY(begin: 0.15, end: 0, delay: 200.ms),

          const SizedBox(height: 6),

          Text(
            user?.role.displayName ?? 'Mentor / Professional',
            style: AppTypography.bodyS.copyWith(
              color: AppColors.white.withOpacity(0.65),
            ),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 18),

          // Quick message prompt
          GestureDetector(
            onTap: () => context.push(AppRoutes.messages),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.chat_rounded,
                      size: 18,
                      color: AppColors.white),
                  const SizedBox(width: 10),
                  Text(
                    'Check your student messages',
                    style: AppTypography.bodyS.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: AppColors.white,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}

// ─── Approval Status Card ─────────────────────────────────────────────────

class _ApprovalStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // In production: read from mentor profile provider
    const isApproved = true;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 20,
          AppSpacing.screenPadding, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isApproved ? AppColors.successLight : AppColors.warningLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isApproved
                ? AppColors.success.withOpacity(0.3)
                : AppColors.warning.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isApproved
                    ? AppColors.success.withOpacity(0.15)
                    : AppColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isApproved
                    ? Icons.verified_rounded
                    : Icons.hourglass_bottom_rounded,
                size: 18,
                color: isApproved
                    ? AppColors.success
                    : AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isApproved
                        ? 'Approved Mentor ✓'
                        : 'Application Under Review',
                    style: AppTypography.labelL.copyWith(
                      color: isApproved
                          ? AppColors.success
                          : Color(0xFF92400E),
                    ),
                  ),
                  Text(
                    isApproved
                        ? 'Students can now book sessions with you'
                        : 'Usually takes 2-3 business days',
                    style: AppTypography.caption.copyWith(
                      color: isApproved
                          ? AppColors.success
                          : Color(0xFF92400E),
                    ),
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

// ─── Mentor Stats ─────────────────────────────────────────────────────────

class _MentorStatsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(mySessionsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 20,
          AppSpacing.screenPadding, 0),
      child: Row(
        children: [
          Expanded(
            child: sessionsAsync.when(
              loading: () => const ShimmerLoader(
                  width: double.infinity,
                  height: 100,
                  borderRadius: 14),
              error: (_, __) => const SizedBox.shrink(),
              data: (sessions) => StatCard(
                value: '${sessions.length}',
                label: 'Total Sessions',
                icon: Icons.calendar_today_rounded,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              value: '4.9⭐',
              label: 'Avg Rating',
              icon: Icons.star_rounded,
              color: AppColors.premiumGold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              value: '47',
              label: 'Reviews',
              icon: Icons.reviews_rounded,
              color: AppColors.accentTeal,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Upcoming Sessions List ───────────────────────────────────────────────

class _UpcomingSessionsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(upcomingSessionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding),
          child: SectionHeader(
            title: '📅 Upcoming Sessions',
            actionLabel: 'Manage',
            onActionTap: () => context.push(AppRoutes.progress),
          ),
        ),
        const SizedBox(height: 12),
        sessionsAsync.when(
          loading: () => Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            child: const ShimmerList(itemCount: 2, itemHeight: 90),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (sessions) {
            if (sessions.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const Text('📭',
                            style: TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text('No upcoming sessions',
                            style: AppTypography.h4),
                        Text('Students will book sessions soon',
                            style: AppTypography.bodyS),
                      ],
                    ),
                  ),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              itemCount: sessions.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  _SessionCard(session: sessions[index])
                      .animate()
                      .fadeIn(
                    delay: Duration(
                        milliseconds: 80 * index),
                  ),
            );
          },
        ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  final dynamic session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.video_call_rounded,
                size: 22, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.topic,
                    style: AppTypography.h4,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  '${session.scheduledAt.day}/${session.scheduledAt.month} • ${session.durationMinutes}min',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          TagChip(
            label: session.status.name,
            backgroundColor: AppColors.infoLight,
            textColor: AppColors.primaryBlue,
            small: true,
          ),
        ],
      ),
    );
  }
}

// ─── Mentor Quick Actions ─────────────────────────────────────────────────

class _MentorQuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 24,
          AppSpacing.screenPadding, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: AppTypography.h3),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MentorAction(
                  icon: Icons.chat_rounded,
                  label: 'Messages',
                  color: AppColors.primaryBlue,
                  onTap: () => context.push(AppRoutes.messages),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MentorAction(
                  icon: Icons.edit_rounded,
                  label: 'Edit Profile',
                  color: AppColors.accentTeal,
                  onTap: () => context.push(AppRoutes.profile),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MentorAction(
                  icon: Icons.forum_rounded,
                  label: 'Community',
                  color: AppColors.premiumPurple,
                  onTap: () => context.go(AppRoutes.community),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MentorAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MentorAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTypography.labelS.copyWith(
                  color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Impact Summary ───────────────────────────────────────────────────────

class _ImpactSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 24,
          AppSpacing.screenPadding, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D4F3C), Color(0xFF065F46)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🌍 Your Impact',
              style: AppTypography.h3
                  .copyWith(color: AppColors.white),
            ),
            const SizedBox(height: 4),
            Text(
              'Lives you\'ve touched through mentorship',
              style: AppTypography.bodyS.copyWith(
                color: AppColors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ImpactStat('134', 'Students\nMentored'),
                _ImpactStat('47', 'Reviews\nReceived'),
                _ImpactStat('98%', 'Satisfaction\nRate'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImpactStat extends StatelessWidget {
  final String value;
  final String label;

  const _ImpactStat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.h1.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.white.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}