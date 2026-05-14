import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_gradients.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/progress_provider.dart';
import '../../../providers/career_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/badges/premium_badge.dart';
import '../../../shared/widgets/badges/tag_chip.dart';
import '../../../shared/widgets/loaders/shimmer_loader.dart';
import '../../../shared/widgets/dialogs/upgrade_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final progressAsync = ref.watch(userProgressProvider);
    final savedCareersAsync = ref.watch(savedCareersProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // ─── Profile hero ──────────────────────────────
          SliverToBoxAdapter(
            child: _ProfileHero(user: user),
          ),

          // ─── Profile completion ────────────────────────
          if (user != null && !user.isProfileComplete)
            SliverToBoxAdapter(
              child: _ProfileCompletionCard(user: user)
                  .animate()
                  .fadeIn(delay: 100.ms),
            ),

          // ─── Stats row ─────────────────────────────────
          SliverToBoxAdapter(
            child: progressAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.screenPadding),
                child: ShimmerLoader(
                    width: double.infinity,
                    height: 80,
                    borderRadius: 16),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (p) => _ProfileStatsRow(progress: p)
                  .animate()
                  .fadeIn(delay: 150.ms),
            ),
          ),

          // ─── About section ─────────────────────────────
          if (user?.bio != null)
            SliverToBoxAdapter(
              child: _AboutSection(bio: user!.bio!)
                  .animate()
                  .fadeIn(delay: 200.ms),
            ),

          // ─── Skills & interests ────────────────────────
          if (user != null &&
              (user.skills.isNotEmpty || user.interests.isNotEmpty))
            SliverToBoxAdapter(
              child: _SkillsSection(user: user)
                  .animate()
                  .fadeIn(delay: 250.ms),
            ),

          // ─── Saved careers ─────────────────────────────
          SliverToBoxAdapter(
            child: savedCareersAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.screenPadding),
                child: ShimmerLoader(
                    width: double.infinity,
                    height: 80,
                    borderRadius: 16),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (careers) => _SavedCareersSection(
                careers: careers,
                onViewAll: () => context.go(AppRoutes.careers),
              ).animate().fadeIn(delay: 300.ms),
            ),
          ),

          // ─── Quick links ───────────────────────────────
          SliverToBoxAdapter(
            child: _QuickLinksSection()
                .animate()
                .fadeIn(delay: 350.ms),
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

// ─── Profile hero ─────────────────────────────────────────────────────────

class _ProfileHero extends StatelessWidget {
  final dynamic user;

  const _ProfileHero({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.heroNavy),
      child: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                children: [
                  // Top bar
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40),
                      Text(
                        'My Profile',
                        style: AppTypography.h3
                            .copyWith(color: AppColors.white),
                      ),
                      // Edit button
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.edit_rounded,
                            size: 18, color: Colors.white),
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 24),

                  // Avatar
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      AvatarWidget(
                        imageUrl: user?.avatarUrl,
                        name: user?.fullName ?? 'User',
                        size: 90,
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            size: 14, color: Colors.white),
                      ),
                    ],
                  )
                      .animate()
                      .scale(
                    begin: const Offset(0.7, 0.7),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  )
                      .fadeIn(duration: 300.ms),

                  const SizedBox(height: 14),

                  // Name + role
                  Text(
                    user?.fullName ?? 'Your Name',
                    style: AppTypography.h1.copyWith(
                      color: AppColors.white,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 4),

                  if (user?.educationLevel != null)
                    Text(
                      '${user!.educationLevel!.displayName} • ${user!.schoolOrUniversity ?? 'UniLink'}',
                      style: AppTypography.bodyS.copyWith(
                        color: AppColors.white.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 250.ms),

                  if (user?.location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 13,
                            color: AppColors.white
                                .withOpacity(0.6)),
                        const SizedBox(width: 3),
                        Text(
                          user!.location!,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 280.ms),
                  ],

                  const SizedBox(height: 14),

                  // Plan badge
                  if (user?.isPro == true)
                    const PremiumBadge(label: 'PRO Member')
                  else
                    GestureDetector(
                      onTap: () => UpgradeDialog.show(
                        context,
                        featureName: 'Pro Features',
                        description:
                        'Unlock unlimited sessions, AI, and more.',
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color:
                              Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                                Icons.auto_awesome_rounded,
                                size: 13,
                                color: AppColors.premiumGold),
                            const SizedBox(width: 5),
                            Text(
                              'Upgrade to Pro',
                              style: AppTypography.labelM.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Profile completion card ──────────────────────────────────────────────

class _ProfileCompletionCard extends StatelessWidget {
  final dynamic user;

  const _ProfileCompletionCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 16,
          AppSpacing.screenPadding, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.infoLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.primaryBlue.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 18, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  'Complete your profile',
                  style: AppTypography.labelL.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
                const Spacer(),
                Text(
                  '${user.profileCompletionPercent}%',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: user.profileCompletionPercent / 100,
                backgroundColor:
                AppColors.primaryBlue.withOpacity(0.15),
                valueColor: const AlwaysStoppedAnimation(
                    AppColors.primaryBlue),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your bio, skills, and interests to get better mentor matches and AI recommendations.',
              style: AppTypography.caption.copyWith(
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Profile stats row ────────────────────────────────────────────────────

class _ProfileStatsRow extends StatelessWidget {
  final dynamic progress;

  const _ProfileStatsRow({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 20,
          AppSpacing.screenPadding, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            _ProfileStat(
              value: '${progress.sessionsCompleted}',
              label: 'Sessions',
            ),
            _Divider(),
            _ProfileStat(
              value: '${progress.careersExplored}',
              label: 'Careers',
            ),
            _Divider(),
            _ProfileStat(
              value: '${progress.totalPoints}',
              label: 'XP Points',
            ),
            _Divider(),
            _ProfileStat(
              value: 'Lv.${progress.currentLevel}',
              label: 'Level',
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.h3.copyWith(
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.borderLight,
    );
  }
}

// ─── About section ────────────────────────────────────────────────────────

class _AboutSection extends StatelessWidget {
  final String bio;

  const _AboutSection({required this.bio});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 20,
          AppSpacing.screenPadding, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'About'),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Text(bio, style: AppTypography.bodyM),
          ),
        ],
      ),
    );
  }
}

// ─── Skills section ───────────────────────────────────────────────────────

class _SkillsSection extends StatelessWidget {
  final dynamic user;

  const _SkillsSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 20,
          AppSpacing.screenPadding, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skills
          if (user.skills.isNotEmpty) ...[
            const SectionHeader(title: '🛠 Skills'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (user.skills as List<String>).map((skill) =>
                  TagChip(
                    label: skill,
                    backgroundColor:
                    AppColors.primaryBlue.withOpacity(0.08),
                    textColor: AppColors.primaryBlue,
                  ),
              ).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Interests
          if (user.interests.isNotEmpty) ...[
            const SectionHeader(title: '💡 Interests'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (user.interests as List<String>).map((interest) =>
                  TagChip(
                    label: interest,
                    backgroundColor:
                    AppColors.accentTeal.withOpacity(0.08),
                    textColor: AppColors.accentTeal,
                  ),
              ).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Saved careers section ────────────────────────────────────────────────

class _SavedCareersSection extends StatelessWidget {
  final List<dynamic> careers;
  final VoidCallback onViewAll;

  const _SavedCareersSection({
    required this.careers,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (careers.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 20,
          AppSpacing.screenPadding, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: '🔖 Saved Careers',
            actionLabel: 'View all',
            onActionTap: onViewAll,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: careers.take(6).map((career) {
              final color = Color(int.parse(
                  career.colorHex.replaceFirst('#', '0xFF')));
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border:
                  Border.all(color: color.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(career.emoji,
                        style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      career.title,
                      style: AppTypography.labelM.copyWith(
                          color: color),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Quick links section ──────────────────────────────────────────────────

class _QuickLinksSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final links = [
      _QuickLink(
        icon: Icons.trending_up_rounded,
        label: 'My Progress',
        color: AppColors.primaryBlue,
        onTap: () => context.push(AppRoutes.progress),
      ),
      _QuickLink(
        icon: Icons.chat_rounded,
        label: 'Messages',
        color: AppColors.accentTeal,
        onTap: () => context.push(AppRoutes.messages),
      ),
      _QuickLink(
        icon: Icons.bookmark_rounded,
        label: 'Saved Items',
        color: AppColors.premiumGold,
        onTap: () => context.go(AppRoutes.careers),
      ),
      _QuickLink(
        icon: Icons.settings_rounded,
        label: 'Settings',
        color: AppColors.textSecondary,
        onTap: () => context.push(AppRoutes.settings),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 20,
          AppSpacing.screenPadding, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Quick Links'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: links.asMap().entries.map((e) {
                final link = e.value;
                final isLast = e.key == links.length - 1;
                return Column(
                  children: [
                    GestureDetector(
                      onTap: link.onTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: link.color
                                    .withOpacity(0.1),
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                              child: Icon(link.icon,
                                  size: 18, color: link.color),
                            ),
                            const SizedBox(width: 12),
                            Text(link.label,
                                style: AppTypography.labelL),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast)
                      const Divider(
                          height: 1,
                          indent: 64,
                          color: AppColors.borderLight),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickLink {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickLink({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}