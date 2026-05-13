import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../models/mentor_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_spacing.dart';
import '../../../providers/mentor_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/loaders/shimmer_loader.dart';
import '../../../shared/widgets/empty_states/empty_state_widget.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/secondary_button.dart';
import '../../../shared/widgets/badges/tag_chip.dart';
import '../widgets/mentor_card.dart';

class MentorDetailScreen extends ConsumerStatefulWidget {
  final String mentorId;

  const MentorDetailScreen({super.key, required this.mentorId});

  @override
  ConsumerState<MentorDetailScreen> createState() =>
      _MentorDetailScreenState();
}

class _MentorDetailScreenState
    extends ConsumerState<MentorDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mentorAsync =
    ref.watch(mentorDetailProvider(widget.mentorId));

    return mentorAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        body: EmptyStateWidget(
          title: 'Could not load mentor',
          message: 'Please try again.',
          emoji: '😕',
          actionLabel: 'Go Back',
          onAction: () => context.pop(),
        ),
      ),
      data: (mentor) {
        if (mentor == null) {
          return Scaffold(
            body: EmptyStateWidget(
              title: 'Mentor not found',
              message: 'This mentor does not exist.',
              emoji: '🔍',
              actionLabel: 'Go Back',
              onAction: () => context.pop(),
            ),
          );
        }
        return _MentorDetailBody(
          mentor: mentor,
          tabController: _tabController,
        );
      },
    );
  }
}

// ─── Main body ────────────────────────────────────────────────────────────

class _MentorDetailBody extends StatelessWidget {
  final MentorModel mentor;
  final TabController tabController;

  const _MentorDetailBody({
    required this.mentor,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            floating: false,
            elevation: 0,
            backgroundColor: AppColors.primaryNavy,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
            actions: [
              // Message button
              GestureDetector(
                onTap: () => context.push(AppRoutes.messages),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Colors.white,
                      size: 20),
                ),
              ),
              // Share button
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.ios_share_rounded,
                    color: Colors.white, size: 20),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _MentorHeroSection(mentor: mentor),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: AppColors.white,
                child: TabBar(
                  controller: tabController,
                  tabs: const [
                    Tab(text: 'About'),
                    Tab(text: 'Reviews'),
                    Tab(text: 'Availability'),
                  ],
                  labelStyle: AppTypography.labelL,
                  unselectedLabelStyle: AppTypography.labelM
                      .copyWith(color: AppColors.textMuted),
                  labelColor: AppColors.primaryBlue,
                  unselectedLabelColor: AppColors.textMuted,
                  indicatorColor: AppColors.primaryBlue,
                  indicatorWeight: 2.5,
                  dividerColor: AppColors.borderLight,
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: tabController,
          children: [
            _AboutTab(mentor: mentor),
            _ReviewsTab(mentor: mentor),
            _AvailabilityTab(mentor: mentor),
          ],
        ),
      ),

      // ─── Bottom CTA ─────────────────────────────────────────
      bottomNavigationBar: _MentorDetailBottomBar(mentor: mentor),
    );
  }
}

// ─── Hero section ─────────────────────────────────────────────────────────

class _MentorHeroSection extends StatelessWidget {
  final MentorModel mentor;

  const _MentorHeroSection({required this.mentor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B1D3A), Color(0xFF1A3A6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Background circles
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentTeal.withOpacity(0.08),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Avatar + verified
                  Row(
                    children: [
                      Stack(
                        children: [
                          AvatarWidget(
                            imageUrl: mentor.avatarUrl,
                            name: mentor.fullName,
                            size: 72,
                          ),
                          if (mentor.isApproved)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.white,
                                      width: 2),
                                ),
                                child: const Icon(
                                    Icons.verified_rounded,
                                    size: 12,
                                    color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              mentor.fullName,
                              style: AppTypography.h2.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              mentor.title,
                              style: AppTypography.bodyS.copyWith(
                                color: AppColors.white
                                    .withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              mentor.company,
                              style: AppTypography.bodyS.copyWith(
                                color: AppColors.accentTealLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 150.ms),

                  const SizedBox(height: 16),

                  // Stats row
                  Row(
                    children: [
                      _HeroStat(
                        value:
                        mentor.rating.toStringAsFixed(1),
                        label: 'Rating',
                        icon: Icons.star_rounded,
                        color: AppColors.premiumGold,
                      ),
                      _StatDivider(),
                      _HeroStat(
                        value: '${mentor.totalReviews}',
                        label: 'Reviews',
                        icon: Icons.reviews_rounded,
                        color: AppColors.accentTealLight,
                      ),
                      _StatDivider(),
                      _HeroStat(
                        value: '${mentor.totalSessions}',
                        label: 'Sessions',
                        icon: Icons.calendar_month_rounded,
                        color: AppColors.white,
                      ),
                      _StatDivider(),
                      _HeroStat(
                        value:
                        '${mentor.yearsOfExperience}yrs',
                        label: 'Experience',
                        icon: Icons.work_rounded,
                        color: AppColors.white,
                      ),
                    ],
                  ).animate().fadeIn(delay: 250.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _HeroStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.h3.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white.withOpacity(0.15),
    );
  }
}

// ─── Tab 1: About ─────────────────────────────────────────────────────────

class _AboutTab extends StatelessWidget {
  final MentorModel mentor;

  const _AboutTab({required this.mentor});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        // Bio
        _DetailCard(
          title: 'About',
          child: Text(mentor.bio, style: AppTypography.bodyM),
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 14),

        // Expertise
        _DetailCard(
          title: '🛠 Areas of Expertise',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: mentor.expertise.map((e) => TagChip(
              label: e,
              backgroundColor:
              AppColors.primaryBlue.withOpacity(0.08),
              textColor: AppColors.primaryBlue,
            )).toList(),
          ),
        ).animate().fadeIn(delay: 150.ms),

        const SizedBox(height: 14),

        // Languages
        _DetailCard(
          title: '🌐 Languages',
          child: Row(
            children: mentor.languages.map((lang) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TagChip(
                label: lang,
                backgroundColor:
                AppColors.accentTeal.withOpacity(0.08),
                textColor: AppColors.accentTeal,
              ),
            )).toList(),
          ),
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 14),

        // Free intro offer
        if (mentor.offersFreeIntro)
          _DetailCard(
            title: '🎁 Free Intro Session',
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.card_giftcard_rounded,
                      color: AppColors.success, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('First session is free',
                          style: AppTypography.labelL),
                      Text(
                        'Book a free 30-min intro call before committing.',
                        style: AppTypography.bodyS,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 250.ms),

        const SizedBox(height: 14),

        // Session price
        _DetailCard(
          title: '💳 Session Pricing',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: mentor.isFree
                      ? const LinearGradient(
                    colors: [
                      AppColors.success,
                      AppColors.accentTeal
                    ],
                  )
                      : const LinearGradient(
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.accentCyan
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  mentor.displayPrice,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  mentor.isFree
                      ? 'This mentor offers completely free sessions. No payment required.'
                      : 'Per 45-minute session. Payment is collected after booking.',
                  style: AppTypography.bodyS,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms),

        const SizedBox(height: 80),
      ],
    );
  }
}

// ─── Tab 2: Reviews ───────────────────────────────────────────────────────

class _ReviewsTab extends StatelessWidget {
  final MentorModel mentor;

  const _ReviewsTab({required this.mentor});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        // Summary card
        _RatingSummaryCard(mentor: mentor)
            .animate()
            .fadeIn(delay: 100.ms),

        const SizedBox(height: 16),

        // Review list
        if (mentor.recentReviews.isEmpty)
          const EmptyStateWidget(
            title: 'No reviews yet',
            message:
            'Be the first to book a session and leave a review.',
            emoji: '⭐',
          )
        else
          ...mentor.recentReviews.asMap().entries.map((e) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MentorReviewCard(review: e.value)
                    .animate()
                    .fadeIn(
                  delay: Duration(
                      milliseconds: 150 + e.key * 80),
                ),
              )),

        const SizedBox(height: 80),
      ],
    );
  }
}

class _RatingSummaryCard extends StatelessWidget {
  final MentorModel mentor;

  const _RatingSummaryCard({required this.mentor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          // Big rating number
          Column(
            children: [
              Text(
                mentor.rating.toStringAsFixed(1),
                style: AppTypography.displayXL.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Row(
                children: List.generate(5, (i) => Icon(
                  i < mentor.rating.round()
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 16,
                  color: AppColors.premiumGold,
                )),
              ),
              const SizedBox(height: 2),
              Text(
                '${mentor.totalReviews} reviews',
                style: AppTypography.caption,
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Bar chart
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                // Mock distribution — real impl from API
                final ratios = [0.7, 0.2, 0.05, 0.03, 0.02];
                final ratio = ratios[5 - star];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      Text('$star',
                          style: AppTypography.caption),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded,
                          size: 10,
                          color: AppColors.premiumGold),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            backgroundColor: AppColors.borderLight,
                            valueColor: const AlwaysStoppedAnimation(
                                AppColors.premiumGold),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${(ratio * 100).round()}%',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab 3: Availability ──────────────────────────────────────────────────

class _AvailabilityTab extends StatelessWidget {
  final MentorModel mentor;

  const _AvailabilityTab({required this.mentor});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        // Status banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: mentor.isAvailable
                ? AppColors.successLight
                : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: mentor.isAvailable
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: mentor.isAvailable
                      ? AppColors.success
                      : AppColors.textMuted,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                mentor.isAvailable
                    ? '${mentor.fullName} is currently accepting new students'
                    : '${mentor.fullName} is not accepting new students at this time',
                style: AppTypography.labelM.copyWith(
                  color: mentor.isAvailable
                      ? AppColors.success
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 16),

        // Available days
        _DetailCard(
          title: '📅 Available Days',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: mentor.availableDays.map((day) =>
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.primaryBlue.withOpacity(0.2)),
                  ),
                  child: Text(
                    day,
                    style: AppTypography.labelM.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
            ).toList(),
          ),
        ).animate().fadeIn(delay: 150.ms),

        const SizedBox(height: 14),

        // Time slots
        _DetailCard(
          title: '🕐 Available Time Slots',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: mentor.availableTimeSlots.map((slot) =>
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accentTeal.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.accentTeal.withOpacity(0.2)),
                  ),
                  child: Text(
                    slot,
                    style: AppTypography.labelM.copyWith(
                      color: AppColors.accentTeal,
                    ),
                  ),
                ),
            ).toList(),
          ),
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 14),

        // Session duration
        _DetailCard(
          title: '⏱ Session Details',
          child: Column(
            children: [
              _DetailRow(
                icon: Icons.timer_rounded,
                label: 'Duration',
                value: '45 minutes per session',
              ),
              const SizedBox(height: 10),
              _DetailRow(
                icon: Icons.video_call_rounded,
                label: 'Format',
                value: 'Video call (link shared after booking)',
              ),
              const SizedBox(height: 10),
              _DetailRow(
                icon: Icons.language_rounded,
                label: 'Language',
                value: mentor.languages.join(', '),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 250.ms),

        const SizedBox(height: 80),
      ],
    );
  }
}

// ─── Shared detail card ───────────────────────────────────────────────────

class _DetailCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _DetailCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.h4),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              size: 18, color: AppColors.primaryBlue),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.caption),
            Text(value, style: AppTypography.labelM),
          ],
        ),
      ],
    );
  }
}

// ─── Bottom bar ───────────────────────────────────────────────────────────

class _MentorDetailBottomBar extends StatelessWidget {
  final MentorModel mentor;

  const _MentorDetailBottomBar({required this.mentor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        14,
        AppSpacing.screenPadding,
        MediaQuery.of(context).padding.bottom + 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Message
          SecondaryButton(
            label: 'Message',
            leadingIcon: Icons.chat_bubble_outline_rounded,
            onPressed: () => context.push(AppRoutes.messages),
            width: 130,
            height: 50,
          ),
          const SizedBox(width: 12),
          // Book session
          Expanded(
            child: PrimaryButton(
              label: mentor.offersFreeIntro
                  ? 'Book Free Session'
                  : 'Book Session',
              isDisabled: !mentor.isAvailable,
              onPressed: mentor.isAvailable
                  ? () => context.push(
                  AppRoutes.bookSessionPath(mentor.id))
                  : null,
              height: 50,
            ),
          ),
        ],
      ),
    );
  }
}