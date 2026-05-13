import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_spacing.dart';

import '../../../models/resource_model.dart';

import '../../../providers/repository_providers.dart';

import '../widgets/resource_card.dart';

import '../../../shared/widgets/inputs/search_bar_widget.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/loaders/shimmer_loader.dart';
import '../../../shared/widgets/empty_states/empty_state_widget.dart';
import '../../../shared/widgets/badges/tag_chip.dart';

/// ─── Providers (local to resources feature) ───────────────────────────────

final _resourcesProvider = FutureProvider.family<
    List<ResourceModel>,
    _ResourceFilter>((ref, filter) async {
  final repo = ref.read(resourceRepositoryProvider);

  return repo.getResources(
    category: filter.category == 'All'
        ? null
        : filter.category,
    type: filter.type,
    aiRecommendedOnly: filter.aiOnly,
    searchQuery: filter.query.isEmpty
        ? null
        : filter.query,
  );
});

final _resourceCategoriesProvider =
FutureProvider<List<String>>((ref) async {
  return ref
      .read(resourceRepositoryProvider)
      .getResourceCategories();
});

class _ResourceFilter {
  final String category;
  final ResourceType? type;
  final bool aiOnly;
  final String query;

  const _ResourceFilter({
    this.category = 'All',
    this.type,
    this.aiOnly = false,
    this.query = '',
  });

  @override
  bool operator ==(Object other) {
    return other is _ResourceFilter &&
        other.category == category &&
        other.type == type &&
        other.aiOnly == aiOnly &&
        other.query == query;
  }

  @override
  int get hashCode =>
      Object.hash(category, type, aiOnly, query);
}

/// ─── Screen ───────────────────────────────────────────────────────────────

class ResourcesScreen extends ConsumerStatefulWidget {
  const ResourcesScreen({super.key});

  @override
  ConsumerState<ResourcesScreen> createState() =>
      _ResourcesScreenState();
}

class _ResourcesScreenState
    extends ConsumerState<ResourcesScreen> {
  final _searchController = TextEditingController();

  String _selectedCategory = 'All';
  ResourceType? _selectedType;
  bool _aiOnly = false;
  String _query = '';

  _ResourceFilter get _filter => _ResourceFilter(
    category: _selectedCategory,
    type: _selectedType,
    aiOnly: _aiOnly,
    query: _query,
  );

  final _typeFilters = <ResourceType?, String>{
    null: 'All Types',
    ResourceType.guide: '📖 Guides',
    ResourceType.video: '🎬 Videos',
    ResourceType.pdf: '📄 PDFs',
    ResourceType.roadmap: '🗺 Roadmaps',
    ResourceType.article: '📝 Articles',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,

      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            backgroundColor: AppColors.white,
            floating: true,
            snap: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,

            title: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Resources',
                  style: AppTypography.h2,
                ),

                Text(
                  'Guides, videos & career roadmaps',
                  style: AppTypography.caption,
                ),
              ],
            ),

            actions: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _aiOnly = !_aiOnly;
                  });
                },

                child: AnimatedContainer(
                  duration:
                  const Duration(milliseconds: 200),

                  margin:
                  const EdgeInsets.only(right: 16),

                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),

                  decoration: BoxDecoration(
                    color: _aiOnly
                        ? AppColors.premiumPurple
                        : AppColors.surfaceMuted,

                    borderRadius:
                    BorderRadius.circular(20),
                  ),

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 13,
                        color: _aiOnly
                            ? AppColors.white
                            : AppColors.textMuted,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        'AI Picks',

                        style:
                        AppTypography.labelS.copyWith(
                          color: _aiOnly
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
              preferredSize:
              const Size.fromHeight(106),

              child: Column(
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      10,
                    ),

                    child: SearchBarWidget(
                      hint: 'Search resources...',
                      controller: _searchController,

                      onChanged: (q) {
                        setState(() {
                          _query = q;
                        });
                      },
                    ),
                  ),

                  SizedBox(
                    height: 36,

                    child: ListView.separated(
                      scrollDirection:
                      Axis.horizontal,

                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),

                      itemCount: _typeFilters.length,

                      separatorBuilder: (_, __) =>
                      const SizedBox(width: 8),

                      itemBuilder: (context, index) {
                        final type = _typeFilters.keys
                            .elementAt(index);

                        final label =
                        _typeFilters.values
                            .elementAt(index);

                        return TagChip(
                          label: label,

                          isSelected:
                          _selectedType == type,

                          onTap: () {
                            setState(() {
                              _selectedType = type;
                            });
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],

        body: _ResourcesBody(filter: _filter),
      ),
    );
  }
}

/// ─── Body ─────────────────────────────────────────────────────────────────

class _ResourcesBody extends ConsumerWidget {
  final _ResourceFilter filter;

  const _ResourcesBody({
    required this.filter,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final resourcesAsync =
    ref.watch(_resourcesProvider(filter));

    final categoriesAsync =
    ref.watch(_resourceCategoriesProvider);

    return CustomScrollView(
      slivers: [
        /// Category chips

        SliverToBoxAdapter(
          child: categoriesAsync.when(
            loading: () =>
            const SizedBox.shrink(),

            error: (_, __) =>
            const SizedBox.shrink(),

            data: (cats) {
              return Padding(
                padding:
                const EdgeInsets.fromLTRB(
                  0,
                  14,
                  0,
                  0,
                ),

                child: _CategoryRow(
                  categories: cats,
                  selected: filter.category,
                  onSelected: (_) {},
                ),
              );
            },
          ),
        ),

        /// AI Picks banner

        if (filter.aiOnly)
          SliverToBoxAdapter(
            child: _AiPicksBanner()
                .animate()
                .fadeIn(duration: 300.ms),
          ),

        /// Resources

        resourcesAsync.when(
          loading: () {
            return SliverPadding(
              padding: const EdgeInsets.all(
                AppSpacing.screenPadding,
              ),

              sliver: SliverList(
                delegate:
                SliverChildBuilderDelegate(
                      (context, index) {
                    return Padding(
                      padding:
                      const EdgeInsets.only(
                        bottom: 12,
                      ),

                      child: const CardSkeleton(
                        height: 110,
                      ),
                    );
                  },
                  childCount: 4,
                ),
              ),
            );
          },

          error: (err, _) {
            return SliverToBoxAdapter(
              child: EmptyStateWidget(
                title:
                'Could not load resources',

                message: err.toString(),

                emoji: '😕',

                actionLabel: 'Retry',

                onAction: () {
                  ref.invalidate(
                    _resourcesProvider(filter),
                  );
                },
              ),
            );
          },

          data: (resources) {
            if (resources.isEmpty) {
              return const SliverToBoxAdapter(
                child: EmptyStateWidget(
                  title: 'No resources found',

                  message:
                  'Try a different category or search term.',

                  emoji: '📭',
                ),
              );
            }

            return SliverPadding(
              padding:
              const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                14,
                AppSpacing.screenPadding,
                AppSpacing.screenPadding,
              ),

              sliver: SliverList(
                delegate:
                SliverChildBuilderDelegate(
                      (context, index) {
                    return Padding(
                      padding:
                      const EdgeInsets.only(
                        bottom: 12,
                      ),

                      child: ResourceCard(
                        resource: resources[index],
                      )
                          .animate()
                          .fadeIn(
                        delay: Duration(
                          milliseconds:
                          60 * index,
                        ),
                        duration: 400.ms,
                      )
                          .slideY(
                        begin: 0.05,
                        end: 0,
                        delay: Duration(
                          milliseconds:
                          60 * index,
                        ),
                        duration: 400.ms,
                      ),
                    );
                  },
                  childCount: resources.length,
                ),
              ),
            );
          },
        ),

        SliverToBoxAdapter(
          child: SizedBox(
            height:
            MediaQuery.of(context)
                .padding
                .bottom +
                80,
          ),
        ),
      ],
    );
  }
}

/// ─── Category Row ────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  const _CategoryRow({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,

      child: ListView.separated(
        scrollDirection: Axis.horizontal,

        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
        ),

        itemCount: categories.length,

        separatorBuilder: (_, __) =>
        const SizedBox(width: 8),

        itemBuilder: (context, index) {
          final cat = categories[index];

          return TagChip(
            label: cat,

            isSelected: selected == cat,

            onTap: () => onSelected(cat),
          );
        },
      ),
    );
  }
}

/// ─── AI Picks Banner ─────────────────────────────────────────────────────

class _AiPicksBanner extends StatelessWidget {
  const _AiPicksBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        14,
        AppSpacing.screenPadding,
        0,
      ),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.premiumPurple,
            Color(0xFF9333EA),
          ],

          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius:
        BorderRadius.circular(14),
      ),

      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 22,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  'AI-Recommended for You',

                  style:
                  AppTypography.labelL.copyWith(
                    color: Colors.white,
                  ),
                ),

                Text(
                  'Based on your interests and profile',

                  style:
                  AppTypography.caption.copyWith(
                    color: Colors.white
                        .withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}