import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_spacing.dart';
import '../../../core/enums/opportunity_type.dart';
import '../../../providers/opportunity_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/inputs/search_bar_widget.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/loaders/shimmer_loader.dart';
import '../../../shared/widgets/empty_states/empty_state_widget.dart';
import '../widgets/opportunity_card.dart';

class OpportunitiesScreen extends ConsumerStatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  ConsumerState<OpportunitiesScreen> createState() =>
      _OpportunitiesScreenState();
}

class _OpportunitiesScreenState
    extends ConsumerState<OpportunitiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _types = [
    null,
    OpportunityType.scholarship,
    OpportunityType.internship,
    OpportunityType.bootcamp,
    OpportunityType.competition,
    OpportunityType.workshop,
    OpportunityType.event,
  ];
  final _typeLabels = [
    'All',
    'Scholarships',
    'Internships',
    'Bootcamps',
    'Competitions',
    'Workshops',
    'Events',
  ];

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: _types.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(selectedOpportunityTypeProvider.notifier).state =
        _types[_tabController.index];
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
                Text('Opportunities', style: AppTypography.h2),
                Text(
                  'Scholarships, internships & more',
                  style: AppTypography.caption,
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(106),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        16, 0, 16, 10),
                    child: SearchBarWidget(
                      hint: 'Search opportunities...',
                      controller: _searchController,
                      onChanged: (_) {},
                    ),
                  ),
                  SizedBox(
                    height: 44,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12),
                      indicator: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelPadding: const EdgeInsets.symmetric(
                          horizontal: 6),
                      tabs: _typeLabels.asMap().entries.map((e) {
                        final type = _types[e.key];
                        return Tab(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (type != null) ...[
                                  Text(type.emoji,
                                      style: const TextStyle(
                                          fontSize: 13)),
                                  const SizedBox(width: 5),
                                ],
                                Text(e.value),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      labelStyle: AppTypography.labelM
                          .copyWith(color: AppColors.white),
                      unselectedLabelStyle:
                      AppTypography.labelM.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      labelColor: AppColors.white,
                      unselectedLabelColor:
                      AppColors.textSecondary,
                      overlayColor: WidgetStateProperty.all(
                          Colors.transparent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: _OpportunitiesBody(),
      ),
    );
  }
}

class _OpportunitiesBody extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oppsAsync = ref.watch(opportunitiesProvider);
    final featuredAsync = ref.watch(featuredOpportunitiesProvider);
    final deadlineAsync =
    ref.watch(deadlineSoonOpportunitiesProvider);
    final type = ref.watch(selectedOpportunityTypeProvider);

    // When filtering, show just the list
    if (type != null) {
      return oppsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: ShimmerList(itemCount: 4, itemHeight: 180),
        ),
        error: (_, __) => const SizedBox.shrink(),
        data: (opps) {
          if (opps.isEmpty) {
            return EmptyStateWidget(
              title: 'No ${type.displayName}s found',
              message: 'Check back later for new opportunities.',
              emoji: type.emoji,
            );
          }
          return ListView.separated(
            padding:
            const EdgeInsets.all(AppSpacing.screenPadding),
            itemCount: opps.length,
            separatorBuilder: (_, __) =>
            const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                OpportunityListCard(
                  opportunity: opps[index],
                  onTap: () => context.push(
                      AppRoutes.opportunityDetailPath(
                          opps[index].id)),
                  onBookmark: () async {
                    final repo =
                    ref.read(opportunityRepositoryProvider);
                    await repo.toggleBookmark(
                      userId: 'usr_001',
                      opportunityId: opps[index].id,
                    );
                    ref.invalidate(opportunitiesProvider);
                  },
                )
                    .animate()
                    .fadeIn(
                  delay: Duration(
                      milliseconds: 60 * index),
                  duration: 400.ms,
                ),
          );
        },
      );
    }

    // Default: sections
    return CustomScrollView(
      slivers: [
        // Deadline soon
        SliverToBoxAdapter(
          child: deadlineAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (opps) {
              if (opps.isEmpty) return const SizedBox.shrink();
              return _DeadlineSoonSection(opportunities: opps);
            },
          ),
        ),

        // Featured
        SliverToBoxAdapter(
          child: featuredAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (opps) => _FeaturedSection(opportunities: opps),
          ),
        ),

        // All
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding, 24,
                AppSpacing.screenPadding, 12),
            child: oppsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (opps) => Text(
                'All Opportunities (${opps.length})',
                style: AppTypography.h3,
              ),
            ),
          ),
        ),

        oppsAsync.when(
          loading: () => SliverPadding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            sliver: SliverList.separated(
              itemCount: 4,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
              itemBuilder: (_, __) =>
              const CardSkeleton(height: 200),
            ),
          ),
          error: (err, _) => SliverToBoxAdapter(
            child: EmptyStateWidget(
              title: 'Could not load opportunities',
              message: err.toString(),
              emoji: '😕',
              actionLabel: 'Retry',
              onAction: () =>
                  ref.invalidate(opportunitiesProvider),
            ),
          ),
          data: (opps) => SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding, 0,
                AppSpacing.screenPadding,
                AppSpacing.screenPadding),
            sliver: SliverList.separated(
              itemCount: opps.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  OpportunityListCard(
                    opportunity: opps[index],
                    onTap: () => context.push(
                        AppRoutes.opportunityDetailPath(
                            opps[index].id)),
                    onBookmark: () async {
                      final repo =
                      ref.read(opportunityRepositoryProvider);
                      await repo.toggleBookmark(
                        userId: 'usr_001',
                        opportunityId: opps[index].id,
                      );
                      ref.invalidate(opportunitiesProvider);
                    },
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

        SliverToBoxAdapter(
          child: SizedBox(
              height: MediaQuery.of(context).padding.bottom + 80),
        ),
      ],
    );
  }
}

// ─── Deadline soon section ────────────────────────────────────────────────

class _DeadlineSoonSection extends StatelessWidget {
  final List<dynamic> opportunities;

  const _DeadlineSoonSection({required this.opportunities});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding),
          child: SectionHeader(title: '⏰ Closing Soon'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            itemCount: opportunities.length,
            separatorBuilder: (_, __) =>
            const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final opp = opportunities[index];
              final daysLeft = opp.daysUntilDeadline as int;
              final isUrgent = daysLeft <= 3;
              return Container(
                width: 190,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUrgent
                      ? AppColors.errorLight
                      : AppColors.warningLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isUrgent
                        ? AppColors.error.withOpacity(0.3)
                        : AppColors.warning.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(opp.type.emoji,
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: isUrgent
                                ? AppColors.error
                                : AppColors.warning,
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
                      opp.title,
                      style: AppTypography.labelL,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      opp.organization,
                      style: AppTypography.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(
                delay: Duration(
                    milliseconds: 60 * index),
                duration: 400.ms,
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── Featured section ─────────────────────────────────────────────────────

class _FeaturedSection extends StatelessWidget {
  final List<dynamic> opportunities;

  const _FeaturedSection({required this.opportunities});

  @override
  Widget build(BuildContext context) {
    if (opportunities.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding),
          child: SectionHeader(title: '⭐ Featured'),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding),
          itemCount: opportunities.take(2).length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: 12),
          itemBuilder: (context, index) => OpportunityListCard(
            opportunity: opportunities[index],
            onTap: () {},
          )
              .animate()
              .fadeIn(
            delay: Duration(milliseconds: 80 * index),
            duration: 400.ms,
          ),
        ),
      ],
    );
  }
}