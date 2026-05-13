import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_spacing.dart';
import '../../../providers/career_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/inputs/search_bar_widget.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/loaders/shimmer_loader.dart';
import '../../../shared/widgets/empty_states/empty_state_widget.dart';
import '../../../shared/widgets/badges/tag_chip.dart';
import '../../../shared/widgets/app_bar_widget.dart';
import '../widgets/career_card.dart';

class CareersScreen extends ConsumerStatefulWidget {
  const CareersScreen({super.key});

  @override
  ConsumerState<CareersScreen> createState() => _CareersScreenState();
}

class _CareersScreenState extends ConsumerState<CareersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _showSavedOnly = false;

  final _categories = [
    'All', 'Technology', 'Healthcare', 'Finance',
    'Business', 'Law', 'Design', 'Education',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(selectedCareerCategoryProvider.notifier).state =
        _categories[_tabController.index];
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // ─── App bar ──────────────────────────────────────────
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
                Text('Explore Careers',
                    style: AppTypography.h2),
                Text(
                  'Find your perfect path',
                  style: AppTypography.caption,
                ),
              ],
            ),
            actions: [
              // Saved filter toggle
              GestureDetector(
                onTap: () =>
                    setState(() => _showSavedOnly = !_showSavedOnly),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: _showSavedOnly
                        ? AppColors.primaryBlue
                        : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bookmark_rounded,
                        size: 14,
                        color: _showSavedOnly
                            ? AppColors.white
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Saved',
                        style: AppTypography.labelS.copyWith(
                          color: _showSavedOnly
                              ? AppColors.white
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(116),
              child: Column(
                children: [
                  // Search
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        16, 0, 16, 12),
                    child: SearchBarWidget(
                      hint: 'Search careers...',
                      controller: _searchController,
                      onChanged: (q) => ref
                          .read(careerSearchQueryProvider.notifier)
                          .state = q,
                    ),
                  ),
                  // Category tabs
                  _CategoryTabBar(
                    controller: _tabController,
                    categories: _categories,
                  ),
                ],
              ),
            ),
          ),
        ],
        body: _CareersBody(showSavedOnly: _showSavedOnly),
      ),
    );
  }
}

// ─── Custom animated category tab bar ─────────────────────────────────────

class _CategoryTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> categories;

  const _CategoryTabBar({
    required this.controller,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        indicator: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
        tabs: categories.map((cat) {
          return Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 0),
              child: Text(cat),
            ),
          );
        }).toList(),
        labelStyle: AppTypography.labelM.copyWith(
          color: AppColors.white,
        ),
        unselectedLabelStyle: AppTypography.labelM.copyWith(
          color: AppColors.textSecondary,
        ),
        unselectedLabelColor: AppColors.textSecondary,
        labelColor: AppColors.white,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }
}

// ─── Careers Body ─────────────────────────────────────────────────────────

class _CareersBody extends ConsumerWidget {
  final bool showSavedOnly;

  const _CareersBody({required this.showSavedOnly});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (showSavedOnly) {
      return _SavedCareersView();
    }

    final careersAsync = ref.watch(careersProvider);
    final trendingAsync = ref.watch(trendingCareersProvider);
    final selectedCategory =
    ref.watch(selectedCareerCategoryProvider);
    final searchQuery = ref.watch(careerSearchQueryProvider);
    final isFiltered =
        selectedCategory != 'All' || searchQuery.isNotEmpty;

    if (isFiltered) {
      return _FilteredCareersView(careersAsync: careersAsync);
    }

    // Default: trending + all
    return CustomScrollView(
      slivers: [
        // Trending section
        SliverToBoxAdapter(
          child: trendingAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.screenPadding),
              child: ShimmerList(itemCount: 2, itemHeight: 200),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (trending) => _TrendingSection(careers: trending),
          ),
        ),

        // All careers header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding, 24,
                AppSpacing.screenPadding, 14),
            child: careersAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (careers) => Text(
                'All Careers (${careers.length})',
                style: AppTypography.h3,
              ),
            ),
          ),
        ),

        // All careers list
        careersAsync.when(
          loading: () => SliverPadding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            sliver: SliverList.separated(
              itemCount: 5,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
              itemBuilder: (_, __) =>
              const CardSkeleton(height: 180),
            ),
          ),
          error: (err, _) => SliverToBoxAdapter(
            child: EmptyStateWidget(
              title: 'Could not load careers',
              message: err.toString(),
              emoji: '😕',
              actionLabel: 'Retry',
              onAction: () => ref.invalidate(careersProvider),
            ),
          ),
          data: (careers) => SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding, 0,
                AppSpacing.screenPadding,
                AppSpacing.screenPadding),
            sliver: SliverList.separated(
              itemCount: careers.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
              itemBuilder: (context, index) => CareerListCard(
                career: careers[index],
                onTap: () => context.push(
                    AppRoutes.careerDetailPath(careers[index].id)),
                onSave: () async {
                  final repo = ref.read(careerRepositoryProvider);
                  await repo.toggleSaveCareer(
                    userId: 'usr_001',
                    careerId: careers[index].id,
                  );
                  ref.invalidate(careersProvider);
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
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(
              height: MediaQuery.of(context).padding.bottom + 80),
        ),
      ],
    );
  }
}

// ─── Trending section ─────────────────────────────────────────────────────

class _TrendingSection extends StatelessWidget {
  final List<dynamic> careers;

  const _TrendingSection({required this.careers});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding),
          child: SectionHeader(title: '🔥 Trending Now'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            itemCount: careers.length,
            separatorBuilder: (_, __) =>
            const SizedBox(width: 12),
            itemBuilder: (context, index) => CompactCareerCard(
              career: careers[index],
              onTap: () => context.push(
                  AppRoutes.careerDetailPath(careers[index].id)),
            )
                .animate()
                .fadeIn(
              delay: Duration(milliseconds: 60 * index),
              duration: 400.ms,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Filtered careers view ────────────────────────────────────────────────

class _FilteredCareersView extends StatelessWidget {
  final AsyncValue<dynamic> careersAsync;

  const _FilteredCareersView({required this.careersAsync});

  @override
  Widget build(BuildContext context) {
    return careersAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: ShimmerList(itemCount: 4, itemHeight: 180),
      ),
      error: (_, __) => const EmptyStateWidget(
        title: 'Something went wrong',
        message: 'Could not load careers. Please try again.',
        emoji: '😕',
      ),
      data: (careers) {
        if (careers.isEmpty) {
          return const EmptyStateWidget(
            title: 'No careers found',
            message: 'Try a different search term or category.',
            emoji: '🔍',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          itemCount: careers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => CareerListCard(
            career: careers[index],
            onTap: () => context.push(
                AppRoutes.careerDetailPath(careers[index].id)),
          )
              .animate()
              .fadeIn(
            delay: Duration(milliseconds: 60 * index),
            duration: 400.ms,
          ),
        );
      },
    );
  }
}

// ─── Saved careers view ───────────────────────────────────────────────────

class _SavedCareersView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(savedCareersProvider);

    return savedAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: ShimmerList(itemCount: 3, itemHeight: 180),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (careers) {
        if (careers.isEmpty) {
          return const EmptyStateWidget(
            title: 'No saved careers',
            message:
            'Bookmark careers you\'re interested in to find them here.',
            emoji: '🔖',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          itemCount: careers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => CareerListCard(
            career: careers[index],
            onTap: () => context.push(
                AppRoutes.careerDetailPath(careers[index].id)),
          ),
        );
      },
    );
  }
}