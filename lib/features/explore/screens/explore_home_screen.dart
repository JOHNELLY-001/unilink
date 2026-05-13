import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_gradients.dart';
import '../../../theme/app_spacing.dart';
import '../../../providers/career_provider.dart';
import '../../../providers/opportunity_provider.dart';
import '../../../providers/mentor_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/inputs/search_bar_widget.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/loaders/shimmer_loader.dart';
import '../../../shared/widgets/empty_states/empty_state_widget.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../core/enums/opportunity_type.dart';
import '../../careers/widgets/career_card.dart';
import '../../opportunities/widgets/opportunity_card.dart';

class ExploreHomeScreen extends ConsumerStatefulWidget {
  const ExploreHomeScreen({super.key});

  @override
  ConsumerState<ExploreHomeScreen> createState() =>
      _ExploreHomeScreenState();
}

class _ExploreHomeScreenState extends ConsumerState<ExploreHomeScreen> {
  final _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final scrolled = _scrollController.offset > 10;
      if (scrolled != _isScrolled) setState(() => _isScrolled = scrolled);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ─── Hero Header ──────────────────────────────────────────
          SliverToBoxAdapter(child: _ExploreHero()),

          // ─── Quick categories ─────────────────────────────────────
          SliverToBoxAdapter(
            child: _QuickCategories()
                .animate()
                .fadeIn(delay: 200.ms)
                .slideY(begin: 0.1, end: 0, delay: 200.ms),
          ),

          // ─── Trending careers ─────────────────────────────────────
          SliverToBoxAdapter(
            child: _TrendingCareersSection()
                .animate()
                .fadeIn(delay: 300.ms),
          ),

          // ─── Featured opportunities ───────────────────────────────
          SliverToBoxAdapter(
            child: _FeaturedOpportunitiesSection()
                .animate()
                .fadeIn(delay: 400.ms),
          ),

          // ─── Meet mentors ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: _MeetMentorsSection()
                .animate()
                .fadeIn(delay: 500.ms),
          ),

          // ─── Sign up CTA ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SignUpCTA()
                .animate()
                .fadeIn(delay: 600.ms),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
                height: MediaQuery.of(context).padding.bottom + 32),
          ),
        ],
      ),
    );
  }
}

// ─── Hero Section ─────────────────────────────────────────────────────────

class _ExploreHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        MediaQuery.of(context).padding.top + 20,
        AppSpacing.screenPadding,
        32,
      ),
      decoration: const BoxDecoration(gradient: AppGradients.heroNavy),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primaryBlue,
                          AppColors.accentTeal,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.link_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'UniLink',
                    style: AppTypography.h3
                        .copyWith(color: AppColors.white),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),

              // Sign in button
              GestureDetector(
                onTap: () => context.push(AppRoutes.signIn),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.25)),
                  ),
                  child: Text(
                    'Sign In',
                    style: AppTypography.labelM
                        .copyWith(color: AppColors.white),
                  ),
                ),
              ).animate().fadeIn(delay: 100.ms),
            ],
          ),

          const SizedBox(height: 32),

          // Headline
          Text(
            'Your future\nstarts here 🇹🇿',
            style: AppTypography.displayL.copyWith(
              color: AppColors.white,
              height: 1.15,
            ),
          )
              .animate()
              .fadeIn(delay: 150.ms, duration: 600.ms)
              .slideY(
            begin: 0.2,
            end: 0,
            delay: 150.ms,
            duration: 600.ms,
            curve: Curves.easeOut,
          ),

          const SizedBox(height: 12),

          Text(
            'Explore career paths, scholarships, and mentors designed for Tanzanian students.',
            style: AppTypography.bodyM.copyWith(
              color: AppColors.white.withOpacity(0.75),
              height: 1.55,
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

          const SizedBox(height: 24),

          // Stats row
          Row(
            children: [
              _StatPill(value: '12+', label: 'Careers'),
              const SizedBox(width: 10),
              _StatPill(value: '50+', label: 'Mentors'),
              const SizedBox(width: 10),
              _StatPill(value: '100+', label: 'Opportunities'),
            ],
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 24),

          // CTA buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      context.push(AppRoutes.signUp, extra: 'student'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        'Get Started Free',
                        style: AppTypography.buttonM.copyWith(
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Text(
                    'Watch Demo',
                    style: AppTypography.buttonM
                        .copyWith(color: AppColors.white),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value;
  final String label;

  const _StatPill({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border:
        Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTypography.labelL.copyWith(
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Categories ─────────────────────────────────────────────────────

class _QuickCategories extends StatelessWidget {
  final _categories = const [
    ('💻', 'Technology'),
    ('🩺', 'Healthcare'),
    ('💰', 'Finance'),
    ('⚖️', 'Law'),
    ('🎨', 'Design'),
    ('🏢', 'Business'),
    ('📚', 'Education'),
    ('🚀', 'Startups'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        const Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding),
          child: SectionHeader(title: 'Explore by Category'),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding),
          child: Row(
            children: _categories.asMap().entries.map((entry) {
              final item = entry.value;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _CategoryChip(
                  emoji: item.$1,
                  label: item.$2,
                  onTap: () => context.push(AppRoutes.signIn),
                )
                    .animate()
                    .fadeIn(
                  delay: Duration(
                      milliseconds: 50 * entry.key),
                  duration: 300.ms,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 10),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 7),
            Text(label, style: AppTypography.labelM),
          ],
        ),
      ),
    );
  }
}

// ─── Trending Careers Section ─────────────────────────────────────────────

class _TrendingCareersSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingAsync = ref.watch(trendingCareersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding),
          child: SectionHeader(
            title: '🔥 Trending Careers',
            actionLabel: 'Sign in to explore',
            onActionTap: () => context.push(AppRoutes.signIn),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 200,
          child: trendingAsync.when(
            loading: () => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              itemCount: 4,
              separatorBuilder: (_, __) =>
              const SizedBox(width: 12),
              itemBuilder: (_, __) =>
              const ShimmerLoader(width: 160, height: 200, borderRadius: 16),
            ),
            error: (_, __) => const EmptyStateWidget(
              title: 'Could not load careers',
              message: 'Please try again',
              emoji: '😕',
            ),
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
                    onTap: () => context.push(AppRoutes.signIn),
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

// ─── Featured Opportunities ───────────────────────────────────────────────

class _FeaturedOpportunitiesSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredAsync = ref.watch(featuredOpportunitiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding),
          child: SectionHeader(
            title: '⭐ Featured Opportunities',
            actionLabel: 'View all',
            onActionTap: () => context.push(AppRoutes.signIn),
          ),
        ),
        const SizedBox(height: 14),
        featuredAsync.when(
          loading: () => Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            child: const ShimmerList(itemCount: 2, itemHeight: 110),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (opps) => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            itemCount: opps.take(3).length,
            separatorBuilder: (_, __) =>
            const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                CompactOpportunityCard(
                  opportunity: opps[index],
                  onTap: () => context.push(AppRoutes.signIn),
                )
                    .animate()
                    .fadeIn(
                  delay: Duration(
                      milliseconds: 80 * index),
                  duration: 400.ms,
                ),
          ),
        ),
      ],
    );
  }
}

// ─── Meet Mentors ─────────────────────────────────────────────────────────

class _MeetMentorsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mentorsAsync = ref.watch(mentorsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding),
          child: SectionHeader(
            title: '🤝 Meet Our Mentors',
            actionLabel: 'See all',
            onActionTap: () => context.push(AppRoutes.signIn),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 220,
          child: mentorsAsync.when(
            loading: () => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              itemCount: 3,
              separatorBuilder: (_, __) =>
              const SizedBox(width: 12),
              itemBuilder: (_, __) => const ShimmerLoader(
                  width: 170, height: 220, borderRadius: 16),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (mentors) => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              itemCount: mentors.take(6).length,
              separatorBuilder: (_, __) =>
              const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _ExploreMentorCard(
                    mentor: mentors[index],
                    onTap: () => context.push(AppRoutes.signIn),
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

class _ExploreMentorCard extends StatelessWidget {
  final dynamic mentor;
  final VoidCallback onTap;

  const _ExploreMentorCard({
    required this.mentor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryNavy.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AvatarWidget(
              imageUrl: mentor.avatarUrl,
              name: mentor.fullName,
              size: 56,
            ),
            const SizedBox(height: 10),
            Text(
              mentor.fullName,
              style: AppTypography.h4,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              mentor.title,
              style: AppTypography.caption,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded,
                    size: 13, color: AppColors.premiumGold),
                const SizedBox(width: 3),
                Text(
                  mentor.rating.toStringAsFixed(1),
                  style: AppTypography.labelM,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    mentor.isFree ? 'Free' : 'Paid',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sign Up CTA ──────────────────────────────────────────────────────────

class _SignUpCTA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        28,
        AppSpacing.screenPadding,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppGradients.heroBlue,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🚀', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            Text(
              'Ready to shape\nyour future?',
              style: AppTypography.h1.copyWith(
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Join thousands of Tanzanian students already building their careers with UniLink.',
              style: AppTypography.bodyM.copyWith(
                color: AppColors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push(
                        AppRoutes.signUp,
                        extra: 'student'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Join as Student',
                          style: AppTypography.buttonM.copyWith(
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => context.push(
                      AppRoutes.signUp,
                      extra: 'mentor'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Text(
                      'Become Mentor',
                      style: AppTypography.buttonM
                          .copyWith(color: AppColors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}