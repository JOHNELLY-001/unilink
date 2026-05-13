import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_spacing.dart';
import '../../../providers/community_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/loaders/shimmer_loader.dart';
import '../../../shared/widgets/empty_states/empty_state_widget.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../widgets/post_card.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() =>
      _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showCreatePost = false;
  final _postController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: AppColors.white,
            floating: true,
            snap: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Community', style: AppTypography.h2),
                Text('Connect with students & mentors',
                    style: AppTypography.caption),
              ],
            ),
            actions: [
              GestureDetector(
                onTap: () => setState(
                        () => _showCreatePost = !_showCreatePost),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _showCreatePost
                        ? AppColors.primaryBlue
                        : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _showCreatePost ? Icons.close_rounded : Icons.edit_rounded,
                    size: 18,
                    color: _showCreatePost
                        ? AppColors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Feed'),
                  Tab(text: 'Trending'),
                  Tab(text: 'Events'),
                ],
                labelStyle: AppTypography.labelL,
                unselectedLabelStyle:
                AppTypography.labelM
                    .copyWith(color: AppColors.textMuted),
                labelColor: AppColors.primaryBlue,
                unselectedLabelColor: AppColors.textMuted,
                indicatorColor: AppColors.primaryBlue,
                indicatorWeight: 2.5,
                dividerColor: AppColors.borderLight,
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            // ─── Create post panel ──────────────────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _showCreatePost
                  ? _CreatePostPanel(
                controller: _postController,
                onSubmit: () async {
                  if (_postController.text.trim().isEmpty) {
                    return;
                  }
                  final repo =
                  ref.read(communityRepositoryProvider);
                  final user = ref.read(currentUserProvider);
                  await repo.createPost(
                    authorId: user?.id ?? 'usr_001',
                    content: _postController.text.trim(),
                  );
                  _postController.clear();
                  setState(() => _showCreatePost = false);
                  ref.invalidate(communityFeedProvider);
                },
              )
                  : const SizedBox.shrink(),
            ),

            // ─── Tab content ────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _FeedTab(),
                  _TrendingTab(),
                  _EventsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Create post panel ────────────────────────────────────────────────────

class _CreatePostPanel extends ConsumerWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const _CreatePostPanel({
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarWidget(
                imageUrl: user?.avatarUrl,
                name: user?.fullName ?? 'You',
                size: 36,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: 4,
                  minLines: 2,
                  style: AppTypography.bodyM
                      .copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText:
                    "Share something with the community...",
                    hintStyle: AppTypography.bodyM,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primaryBlue,
                          width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                    filled: true,
                    fillColor: AppColors.surfaceMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onSubmit,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Post',
                    style: AppTypography.buttonS,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(
      begin: -0.05,
      end: 0,
      duration: 250.ms,
    );
  }
}

// ─── Feed tab ─────────────────────────────────────────────────────────────

class _FeedTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(communityFeedProvider);

    return feedAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: ShimmerList(itemCount: 3, itemHeight: 200),
      ),
      error: (err, _) => EmptyStateWidget(
        title: 'Could not load posts',
        message: err.toString(),
        emoji: '😕',
        actionLabel: 'Retry',
        onAction: () => ref.invalidate(communityFeedProvider),
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return const EmptyStateWidget(
            title: 'No posts yet',
            message:
            'Be the first to share something with the community!',
            emoji: '✍️',
          );
        }
        return RefreshIndicator(
          color: AppColors.primaryBlue,
          onRefresh: () async {
            ref.invalidate(communityFeedProvider);
            await Future.delayed(const Duration(milliseconds: 800));
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            itemCount: posts.length,
            separatorBuilder: (_, __) =>
            const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                post: post,
                onReact: () async {
                  final repo =
                  ref.read(communityRepositoryProvider);
                  await repo.reactToPost(
                    postId: post.id,
                    userId: 'usr_001',
                    emoji: '❤️',
                  );
                  ref.invalidate(communityFeedProvider);
                },
                onVote: (optionId) async {
                  final repo =
                  ref.read(communityRepositoryProvider);
                  await repo.voteOnPoll(
                    postId: post.id,
                    optionId: optionId,
                    userId: 'usr_001',
                  );
                  ref.invalidate(communityFeedProvider);
                },
              )
                  .animate()
                  .fadeIn(
                delay: Duration(
                    milliseconds: 60 * index),
                duration: 400.ms,
              )
                  .slideY(
                begin: 0.05,
                end: 0,
                delay: Duration(
                    milliseconds: 60 * index),
                duration: 400.ms,
                curve: Curves.easeOut,
              );
            },
          ),
        );
      },
    );
  }
}

// ─── Trending tab ─────────────────────────────────────────────────────────

class _TrendingTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingAsync = ref.watch(trendingPostsProvider);

    return trendingAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: ShimmerList(itemCount: 3, itemHeight: 180),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (posts) => ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        itemCount: posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rank number
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(top: 12, right: 10),
              decoration: BoxDecoration(
                color: index == 0
                    ? AppColors.premiumGold
                    : index == 1
                    ? AppColors.textMuted
                    : AppColors.borderLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: AppTypography.labelM.copyWith(
                    color: index < 2
                        ? AppColors.white
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PostCard(
                post: posts[index],
              ).animate().fadeIn(
                delay: Duration(
                    milliseconds: 80 * index),
                duration: 400.ms,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Events tab ───────────────────────────────────────────────────────────

class _EventsTab extends StatelessWidget {
  final _events = const [
    _EventItem(
      emoji: '🎓',
      title: 'UDSM Open Day 2025',
      date: 'Jan 18 • 9:00 AM',
      location: 'UDSM Campus, Dar es Salaam',
      attendees: 420,
      color: AppColors.primaryBlue,
    ),
    _EventItem(
      emoji: '💼',
      title: 'Tech Career Fair — Dar es Salaam',
      date: 'Feb 3 • 10:00 AM',
      location: 'Julius Nyerere Convention Centre',
      attendees: 1200,
      color: AppColors.accentTeal,
    ),
    _EventItem(
      emoji: '🤝',
      title: 'UniLink Mentor Networking Night',
      date: 'Feb 14 • 6:00 PM',
      location: 'Online (Zoom)',
      attendees: 89,
      color: AppColors.premiumPurple,
    ),
    _EventItem(
      emoji: '🚀',
      title: 'Entrepreneurship Bootcamp — Buni Hub',
      date: 'Mar 1 • 8:00 AM',
      location: 'Buni Innovation Hub, Dar es Salaam',
      attendees: 60,
      color: AppColors.warning,
    ),
  ];

  const _EventsTab();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: _events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _EventCard(
        event: _events[index],
      )
          .animate()
          .fadeIn(
        delay: Duration(milliseconds: 80 * index),
        duration: 400.ms,
      )
          .slideY(
        begin: 0.05,
        end: 0,
        delay: Duration(milliseconds: 80 * index),
        duration: 400.ms,
      ),
    );
  }
}

class _EventItem {
  final String emoji;
  final String title;
  final String date;
  final String location;
  final int attendees;
  final Color color;

  const _EventItem({
    required this.emoji,
    required this.title,
    required this.date,
    required this.location,
    required this.attendees,
    required this.color,
  });
}

class _EventCard extends StatelessWidget {
  final _EventItem event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: event.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(event.emoji,
                  style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style: AppTypography.h4,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(event.date,
                        style: AppTypography.caption),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(event.location,
                          style: AppTypography.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.people_rounded,
                        size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${event.attendees} attending',
                      style: AppTypography.caption,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: event.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'RSVP',
                        style: AppTypography.labelS.copyWith(
                          color: event.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}