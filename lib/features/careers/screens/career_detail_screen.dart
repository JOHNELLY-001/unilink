import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../models/career_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_spacing.dart';
import '../../../providers/career_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/loaders/shimmer_loader.dart';
import '../../../shared/widgets/empty_states/empty_state_widget.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/secondary_button.dart';

class CareerDetailScreen extends ConsumerStatefulWidget {
  final String careerId;

  const CareerDetailScreen({super.key, required this.careerId});

  @override
  ConsumerState<CareerDetailScreen> createState() =>
      _CareerDetailScreenState();
}

class _CareerDetailScreenState
    extends ConsumerState<CareerDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSaved = false;

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
    final careerAsync =
    ref.watch(careerDetailProvider(widget.careerId));

    return careerAsync.when(
      loading: () => Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              SizedBox(
                  height: MediaQuery.of(context).padding.top + 16),
              const ShimmerLoader(
                  width: double.infinity,
                  height: 300,
                  borderRadius: 0),
              const SizedBox(height: 20),
              const ShimmerList(itemCount: 3, itemHeight: 80),
            ],
          ),
        ),
      ),
      error: (_, __) => Scaffold(
        body: EmptyStateWidget(
          title: 'Career not found',
          message: 'This career could not be loaded.',
          emoji: '😕',
          actionLabel: 'Go Back',
          onAction: () => context.pop(),
        ),
      ),
      data: (career) {
        if (career == null) {
          return Scaffold(
            body: EmptyStateWidget(
              title: 'Career not found',
              message: 'This career does not exist.',
              emoji: '🔍',
              actionLabel: 'Go Back',
              onAction: () => context.pop(),
            ),
          );
        }
        _isSaved = career.isSaved;
        return _CareerDetailBody(
          career: career,
          tabController: _tabController,
          isSaved: _isSaved,
          onSave: () async {
            HapticFeedback.mediumImpact();
            await ref.read(careerRepositoryProvider).toggleSaveCareer(
              userId: 'usr_001',
              careerId: career.id,
            );
            ref.invalidate(careerDetailProvider(widget.careerId));
          },
          onAskAi: () {
            context.go(AppRoutes.aiAssistant);
          },
          onFindMentor: () {
            context.go(AppRoutes.mentors);
          },
        );
      },
    );
  }
}

// ─── Main body ────────────────────────────────────────────────────────────

class _CareerDetailBody extends StatelessWidget {
  final CareerModel career;
  final TabController tabController;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onAskAi;
  final VoidCallback onFindMentor;

  const _CareerDetailBody({
    required this.career,
    required this.tabController,
    required this.isSaved,
    required this.onSave,
    required this.onAskAi,
    required this.onFindMentor,
  });

  Color get _cardColor =>
      Color(int.parse(career.colorHex.replaceFirst('#', '0xFF')));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // ─── Hero sliver ─────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: _cardColor,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
            actions: [
              // Save button
              GestureDetector(
                onTap: onSave,
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      key: ValueKey(isSaved),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              // Share button
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.ios_share_rounded,
                    color: Colors.white, size: 20),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _HeroBackground(
                career: career,
                cardColor: _cardColor,
              ),
            ),
            // Tab bar
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: AppColors.white,
                child: TabBar(
                  controller: tabController,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Pathways'),
                    Tab(text: 'Salaries'),
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
            // Tab 1: Overview
            _OverviewTab(career: career, cardColor: _cardColor),
            // Tab 2: Pathways
            _PathwaysTab(career: career, cardColor: _cardColor),
            // Tab 3: Salaries
            _SalariesTab(career: career, cardColor: _cardColor),
          ],
        ),
      ),

      // ─── Bottom CTA ───────────────────────────────────────────
      bottomNavigationBar: _BottomCTA(
        onAskAi: onAskAi,
        onFindMentor: onFindMentor,
        cardColor: _cardColor,
      ),
    );
  }
}

// ─── Hero Background ──────────────────────────────────────────────────────

class _HeroBackground extends StatelessWidget {
  final CareerModel career;
  final Color cardColor;

  const _HeroBackground({
    required this.career,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardColor, cardColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Emoji
                  Text(career.emoji,
                      style: const TextStyle(fontSize: 48))
                      .animate()
                      .scale(
                    begin: const Offset(0.5, 0.5),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),

                  const SizedBox(height: 12),

                  // Title
                  Text(
                    career.title,
                    style: AppTypography.displayM.copyWith(
                      color: AppColors.white,
                    ),
                  ).animate().fadeIn(delay: 150.ms),

                  const SizedBox(height: 6),

                  // Category + trending
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          career.category,
                          style: AppTypography.labelM.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      if (career.isTrending) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '🔥 Trending',
                            style: AppTypography.labelM.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
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

// ─── Tab 1: Overview ──────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final CareerModel career;
  final Color cardColor;

  const _OverviewTab({
    required this.career,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        // Description
        _SectionCard(
          title: 'About this Career',
          child: Text(career.description, style: AppTypography.bodyM),
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 16),

        // Key metrics
        _SectionCard(
          title: 'At a Glance',
          child: Row(
            children: [
              Expanded(
                child: _MetricItem(
                  icon: Icons.trending_up_rounded,
                  label: 'Growth',
                  value: career.growthOutlook.toUpperCase(),
                  color: career.growthOutlook == 'high'
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
              Expanded(
                child: _MetricItem(
                  icon: Icons.people_rounded,
                  label: 'Demand',
                  value: career.demandLevel.toUpperCase(),
                  color: career.demandLevel == 'high'
                      ? AppColors.primaryBlue
                      : AppColors.warning,
                ),
              ),
              Expanded(
                child: _MetricItem(
                  icon: Icons.payments_rounded,
                  label: 'Entry Salary',
                  value: career.salaryInsight.entryDisplay,
                  color: AppColors.accentTeal,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 150.ms),

        const SizedBox(height: 16),

        // Required skills
        _SectionCard(
          title: '🛠 Required Skills',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: career.requiredSkills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: cardColor.withOpacity(0.2)),
                ),
                child: Text(
                  skill,
                  style: AppTypography.labelM.copyWith(
                    color: cardColor,
                  ),
                ),
              );
            }).toList(),
          ),
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 16),

        // Recommended subjects
        if (career.recommendedSubjects.isNotEmpty)
          _SectionCard(
            title: '📚 Recommended A-Level Subjects',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: career.recommendedSubjects.map((subj) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    subj,
                    style: AppTypography.labelM.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                );
              }).toList(),
            ),
          ).animate().fadeIn(delay: 250.ms),

        const SizedBox(height: 16),

        // Top companies
        _SectionCard(
          title: '🏢 Top Employers in Tanzania',
          child: Column(
            children: career.topCompanies.asMap().entries.map((e) {
              return Padding(
                padding: EdgeInsets.only(
                    bottom: e.key < career.topCompanies.length - 1
                        ? 10
                        : 0),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: cardColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(e.value, style: AppTypography.bodyM),
                  ],
                ),
              );
            }).toList(),
          ),
        ).animate().fadeIn(delay: 300.ms),

        const SizedBox(height: 80),
      ],
    );
  }
}

// ─── Tab 2: Pathways ──────────────────────────────────────────────────────

class _PathwaysTab extends StatelessWidget {
  final CareerModel career;
  final Color cardColor;

  const _PathwaysTab({
    required this.career,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        // Career progression
        _SectionCard(
          title: '📈 Career Progression',
          child: Column(
            children: career.careerPaths.map((path) {
              final steps = path.split('→');
              return _CareerPathWidget(
                steps: steps.map((s) => s.trim()).toList(),
                color: cardColor,
              );
            }).toList(),
          ),
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 16),

        // University pathways
        _SectionCard(
          title: '🏛 Universities in Tanzania',
          child: Column(
            children: career.universityPathways
                .asMap()
                .entries
                .map((e) {
              final index = e.key;
              final pathway = e.value;
              // Split "Uni - Program" format
              final parts = pathway.split(' - ');
              final uni = parts.isNotEmpty ? parts[0] : pathway;
              final program =
              parts.length > 1 ? parts[1] : '';

              return Container(
                margin: EdgeInsets.only(
                    bottom:
                    index < career.universityPathways.length - 1
                        ? 12
                        : 0),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.school_rounded,
                          size: 20, color: cardColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(uni,
                              style: AppTypography.labelL),
                          if (program.isNotEmpty)
                            Text(program,
                                style: AppTypography.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ).animate().fadeIn(delay: 150.ms),

        const SizedBox(height: 16),

        // Alternative routes
        _SectionCard(
          title: '💡 Alternative Pathways',
          child: Column(
            children: [
              _AlternativeRoute(
                icon: '🌐',
                title: 'Online Courses',
                description:
                'Coursera, edX, and LinkedIn Learning offer recognized certifications.',
                color: cardColor,
              ),
              const SizedBox(height: 10),
              _AlternativeRoute(
                icon: '🚀',
                title: 'Bootcamps & Intensive Programs',
                description:
                'ALX Africa, Moringa School, and others offer fast-track programs.',
                color: cardColor,
              ),
              const SizedBox(height: 10),
              _AlternativeRoute(
                icon: '🏢',
                title: 'Apprenticeships',
                description:
                'Some companies hire and train directly. Ask mentors about these.',
                color: cardColor,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 80),
      ],
    );
  }
}

class _CareerPathWidget extends StatelessWidget {
  final List<String> steps;
  final Color color;

  const _CareerPathWidget({
    required this.steps,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: steps.asMap().entries.map((e) {
        final index = e.key;
        final step = e.value;
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isLast
                        ? color
                        : color.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: color.withOpacity(0.4),
                        width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: AppTypography.caption.copyWith(
                        color: isLast
                            ? Colors.white
                            : color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 24,
                    color: color.withOpacity(0.2),
                    margin: const EdgeInsets.symmetric(vertical: 2),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 8),
                child: Text(
                  step,
                  style: AppTypography.bodyS.copyWith(
                    color: isLast
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: isLast
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _AlternativeRoute extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final Color color;

  const _AlternativeRoute({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelL),
                const SizedBox(height: 2),
                Text(description, style: AppTypography.bodyS),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab 3: Salaries ──────────────────────────────────────────────────────

class _SalariesTab extends StatelessWidget {
  final CareerModel career;
  final Color cardColor;

  const _SalariesTab({
    required this.career,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final salary = career.salaryInsight;
    final maxSalary = salary.seniorLevelTzs.toDouble();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        // Visual salary bars
        _SectionCard(
          title: '💰 Salary Ranges in Tanzania (Monthly)',
          child: Column(
            children: [
              _SalaryBar(
                level: 'Entry Level',
                subtitle: '0–2 years experience',
                amount: salary.entryLevelTzs,
                maxAmount: maxSalary,
                color: AppColors.accentTeal,
                displayText: salary.entryDisplay,
                animationDelay: 100,
              ),
              const SizedBox(height: 16),
              _SalaryBar(
                level: 'Mid Level',
                subtitle: '3–6 years experience',
                amount: salary.midLevelTzs,
                maxAmount: maxSalary,
                color: AppColors.primaryBlue,
                displayText: salary.midDisplay,
                animationDelay: 200,
              ),
              const SizedBox(height: 16),
              _SalaryBar(
                level: 'Senior Level',
                subtitle: '7+ years experience',
                amount: salary.seniorLevelTzs,
                maxAmount: maxSalary,
                color: cardColor,
                displayText: salary.seniorDisplay,
                animationDelay: 300,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 16),

        // Salary growth card
        _SalaryGrowthCard(
          career: career,
          cardColor: cardColor,
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 16),

        // Factors affecting salary
        _SectionCard(
          title: '📊 Factors That Affect Your Salary',
          child: Column(
            children: [
              _SalaryFactor(
                icon: Icons.school_rounded,
                factor: 'Education Level',
                impact: 'High impact',
                color: AppColors.primaryBlue,
              ),
              const SizedBox(height: 10),
              _SalaryFactor(
                icon: Icons.work_rounded,
                factor: 'Years of Experience',
                impact: 'Very high impact',
                color: AppColors.success,
              ),
              const SizedBox(height: 10),
              _SalaryFactor(
                icon: Icons.location_city_rounded,
                factor: 'Location (Dar vs upcountry)',
                impact: 'Medium impact',
                color: AppColors.warning,
              ),
              const SizedBox(height: 10),
              _SalaryFactor(
                icon: Icons.business_rounded,
                factor: 'Industry (Private vs Govt)',
                impact: 'High impact',
                color: AppColors.accentTeal,
              ),
              const SizedBox(height: 10),
              _SalaryFactor(
                icon: Icons.language_rounded,
                factor: 'Remote / International work',
                impact: 'Very high impact',
                color: cardColor,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms),

        const SizedBox(height: 16),

        // Remote salary note
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cardColor.withOpacity(0.08),
                cardColor.withOpacity(0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border:
            Border.all(color: cardColor.withOpacity(0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🌍', style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Remote Work Premium',
                        style: AppTypography.h4),
                    const SizedBox(height: 4),
                    Text(
                      'Senior ${career.title} professionals working for international companies remotely from Tanzania can earn \$3,000–\$10,000+/month in USD.',
                      style: AppTypography.bodyS,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 350.ms),

        const SizedBox(height: 80),
      ],
    );
  }
}

class _SalaryBar extends StatefulWidget {
  final String level;
  final String subtitle;
  final int amount;
  final double maxAmount;
  final Color color;
  final String displayText;
  final int animationDelay;

  const _SalaryBar({
    required this.level,
    required this.subtitle,
    required this.amount,
    required this.maxAmount,
    required this.color,
    required this.displayText,
    required this.animationDelay,
  });

  @override
  State<_SalaryBar> createState() => _SalaryBarState();
}

class _SalaryBarState extends State<_SalaryBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(
        parent: _controller, curve: Curves.easeOutCubic);

    Future.delayed(
        Duration(milliseconds: widget.animationDelay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratio = widget.amount / widget.maxAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.level, style: AppTypography.labelL),
                Text(widget.subtitle,
                    style: AppTypography.caption),
              ],
            ),
            Text(
              widget.displayText,
              style: AppTypography.h4.copyWith(
                color: widget.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, _) => LinearProgressIndicator(
              value: ratio * _animation.value,
              backgroundColor: AppColors.borderLight,
              valueColor: AlwaysStoppedAnimation(widget.color),
              minHeight: 10,
            ),
          ),
        ),
      ],
    );
  }
}

class _SalaryGrowthCard extends StatelessWidget {
  final CareerModel career;
  final Color cardColor;

  const _SalaryGrowthCard({
    required this.career,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final salary = career.salaryInsight;
    final growthMultiplier =
        salary.seniorLevelTzs / salary.entryLevelTzs;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardColor, cardColor.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${growthMultiplier.toStringAsFixed(1)}x',
                  style: AppTypography.displayL.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Salary growth potential',
                  style: AppTypography.bodyS.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'From entry to senior level',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                salary.entryDisplay,
                style: AppTypography.bodyS.copyWith(
                  color: AppColors.white.withOpacity(0.7),
                ),
              ),
              Text(
                '↓',
                style: AppTypography.bodyS.copyWith(
                    color: AppColors.white.withOpacity(0.5)),
              ),
              Text(
                salary.seniorDisplay,
                style: AppTypography.h2.copyWith(
                  color: AppColors.white,
                ),
              ),
              Text(
                'per month',
                style: AppTypography.caption.copyWith(
                  color: AppColors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SalaryFactor extends StatelessWidget {
  final IconData icon;
  final String factor;
  final String impact;
  final Color color;

  const _SalaryFactor({
    required this.icon,
    required this.factor,
    required this.impact,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(factor, style: AppTypography.labelM)),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            impact,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shared section card ──────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.h4),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(value,
            style: AppTypography.labelM
                .copyWith(color: color)),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}

// ─── Bottom CTA ───────────────────────────────────────────────────────────

class _BottomCTA extends StatelessWidget {
  final VoidCallback onAskAi;
  final VoidCallback onFindMentor;
  final Color cardColor;

  const _BottomCTA({
    required this.onAskAi,
    required this.onFindMentor,
    required this.cardColor,
  });

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
          Expanded(
            child: SecondaryButton(
              label: 'Ask AI',
              leadingIcon: Icons.smart_toy_rounded,
              onPressed: onAskAi,
              height: 48,
              borderColor: cardColor,
              textColor: cardColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryButton(
              label: 'Find a Mentor',
              leadingIcon: Icons.people_rounded,
              onPressed: onFindMentor,
              height: 48,
              gradient: LinearGradient(
                colors: [cardColor, cardColor.withOpacity(0.8)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}