import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_spacing.dart';
import '../../../providers/mentor_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/inputs/search_bar_widget.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/loaders/shimmer_loader.dart';
import '../../../shared/widgets/empty_states/empty_state_widget.dart';
import '../../../shared/widgets/badges/tag_chip.dart';
import '../widgets/mentor_card.dart';

class MentorsScreen extends ConsumerStatefulWidget {
  const MentorsScreen({super.key});

  @override
  ConsumerState<MentorsScreen> createState() => _MentorsScreenState();
}

class _MentorsScreenState extends ConsumerState<MentorsScreen> {
  final _searchController = TextEditingController();
  bool _availableOnly = false;
  bool _freeOnly = false;
  bool _isGridView = false;

  final _categories = [
    'All',
    'Software Engineering',
    'Finance',
    'Medicine',
    'Law',
    'Design',
    'Engineering',
  ];
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilters() {
    ref.read(mentorFilterProvider.notifier).update((f) => f.copyWith(
      category: _selectedCategory == 'All' ? null : _selectedCategory,
      searchQuery: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      availableOnly: _availableOnly,
      freeOnly: _freeOnly,
    ));
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
                Text('Find a Mentor', style: AppTypography.h2),
                Text('Learn from verified professionals',
                    style: AppTypography.caption),
              ],
            ),
            actions: [
              // Grid/list toggle
              GestureDetector(
                onTap: () =>
                    setState(() => _isGridView = !_isGridView),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _isGridView
                        ? Icons.view_list_rounded
                        : Icons.grid_view_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(130),
              child: Column(
                children: [
                  // Search
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        16, 0, 16, 10),
                    child: SearchBarWidget(
                      hint: 'Search mentors, expertise...',
                      controller: _searchController,
                      onChanged: (_) => _updateFilters(),
                    ),
                  ),
                  // Filter chips row
                  _FilterRow(
                    availableOnly: _availableOnly,
                    freeOnly: _freeOnly,
                    onAvailableToggled: () {
                      setState(
                              () => _availableOnly = !_availableOnly);
                      _updateFilters();
                    },
                    onFreeToggled: () {
                      setState(() => _freeOnly = !_freeOnly);
                      _updateFilters();
                    },
                  ),
                  // Category chips
                  _CategoryRow(
                    categories: _categories,
                    selected: _selectedCategory,
                    onSelected: (cat) {
                      setState(() => _selectedCategory = cat);
                      _updateFilters();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
        body: _MentorsBody(isGridView: _isGridView),
      ),
    );
  }
}

// ─── Filter row ───────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final bool availableOnly;
  final bool freeOnly;
  final VoidCallback onAvailableToggled;
  final VoidCallback onFreeToggled;

  const _FilterRow({
    required this.availableOnly,
    required this.freeOnly,
    required this.onAvailableToggled,
    required this.onFreeToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          _FilterChip(
            label: '🟢 Available now',
            isActive: availableOnly,
            onTap: onAvailableToggled,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '🆓 Free sessions',
            isActive: freeOnly,
            onTap: onFreeToggled,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryBlue
              : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColors.primaryBlue
                : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelS.copyWith(
            color: isActive
                ? AppColors.white
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Category row ─────────────────────────────────────────────────────────

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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
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

// ─── Mentors body ─────────────────────────────────────────────────────────

class _MentorsBody extends ConsumerWidget {
  final bool isGridView;

  const _MentorsBody({required this.isGridView});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mentorsAsync = ref.watch(mentorsProvider);
    final recommendedAsync = ref.watch(recommendedMentorsProvider);

    return mentorsAsync.when(
      loading: () => isGridView
          ? _GridSkeleton()
          : const Padding(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: ShimmerList(
            itemCount: 4,
            itemHeight: 200,
            itemBuilder: MentorCardSkeleton.new),
      ),
      error: (err, _) => EmptyStateWidget(
        title: 'Could not load mentors',
        message: err.toString(),
        emoji: '😕',
        actionLabel: 'Retry',
        onAction: () => ref.invalidate(mentorsProvider),
      ),
      data: (mentors) {
        if (mentors.isEmpty) {
          return const EmptyStateWidget(
            title: 'No mentors found',
            message:
            'Try adjusting your filters or search term.',
            emoji: '🔍',
          );
        }

        return CustomScrollView(
          slivers: [
            // Recommended section (only when no filter active)
            SliverToBoxAdapter(
              child: recommendedAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (recommended) {
                  if (recommended.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return _RecommendedSection(
                      mentors: recommended);
                },
              ),
            ),

            // All mentors header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding, 20,
                    AppSpacing.screenPadding, 12),
                child: SectionHeader(
                  title: 'All Mentors (${mentors.length})',
                ),
              ),
            ),

            // Grid or list
            if (isGridView)
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                  children: mentors.asMap().entries.map((e) {
                    return MentorGridCard(
                      mentor: e.value,
                      onTap: () => context.push(
                          AppRoutes.mentorDetailPath(e.value.id)),
                    )
                        .animate()
                        .fadeIn(
                      delay: Duration(
                          milliseconds: 50 * e.key),
                      duration: 400.ms,
                    );
                  }).toList(),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding),
                sliver: SliverList.separated(
                  itemCount: mentors.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      MentorListCard(
                        mentor: mentors[index],
                        onTap: () => context.push(
                            AppRoutes.mentorDetailPath(
                                mentors[index].id)),
                        onBook: () => context.push(
                            AppRoutes.bookSessionPath(
                                mentors[index].id)),
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
                      ),
                ),
              ),

            SliverToBoxAdapter(
              child: SizedBox(
                height:
                MediaQuery.of(context).padding.bottom + 100,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Recommended mentors horizontal section ───────────────────────────────

class _RecommendedSection extends StatelessWidget {
  final List<dynamic> mentors;

  const _RecommendedSection({required this.mentors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding),
          child: SectionHeader(title: '✨ Recommended for You'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            itemCount: mentors.length,
            separatorBuilder: (_, __) =>
            const SizedBox(width: 12),
            itemBuilder: (context, index) => MentorGridCard(
              mentor: mentors[index],
              onTap: () => context.push(
                  AppRoutes.mentorDetailPath(mentors[index].id)),
            )
                .animate()
                .fadeIn(
              delay: Duration(milliseconds: 60 * index),
              duration: 400.ms,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── Grid skeleton ────────────────────────────────────────────────────────

class _GridSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
          6,
              (_) => const ShimmerLoader(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 16),
        ),
      ),
    );
  }
}