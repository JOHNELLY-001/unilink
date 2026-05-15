import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_gradients.dart';
import '../../../theme/app_spacing.dart';
import '../../../shared/widgets/buttons/primary_button.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  int _selectedPlanIndex = 1; // default: Pro
  bool _isAnnual = true;

  final _plans = [
    _Plan(
      id: 'free',
      name: 'Free',
      monthlyPrice: 0,
      annualPrice: 0,
      color: AppColors.textMuted,
      description: 'Get started on your journey',
      features: [
        _PlanFeature('Explore careers', true),
        _PlanFeature('Browse opportunities', true),
        _PlanFeature('Community access', true),
        _PlanFeature('AI chat (10 msgs/day)', true),
        _PlanFeature('Unlimited AI chat', false),
        _PlanFeature('Mentor sessions', false),
        _PlanFeature('Advanced filters', false),
        _PlanFeature('Priority support', false),
      ],
    ),
    _Plan(
      id: 'pro',
      name: 'Pro',
      monthlyPrice: 9,
      annualPrice: 79,
      color: AppColors.primaryBlue,
      description: 'For serious students',
      isMostPopular: true,
      features: [
        _PlanFeature('Everything in Free', true),
        _PlanFeature('Unlimited AI chat', true),
        _PlanFeature('5 mentor sessions/month', true),
        _PlanFeature('Advanced career filters', true),
        _PlanFeature('Scholarship alerts', true),
        _PlanFeature('Career roadmaps', true),
        _PlanFeature('Priority support', false),
        _PlanFeature('Unlimited mentor sessions', false),
      ],
    ),
    _Plan(
      id: 'premium',
      name: 'Premium',
      monthlyPrice: 19,
      annualPrice: 159,
      color: AppColors.premiumPurple,
      description: 'The complete experience',
      features: [
        _PlanFeature('Everything in Pro', true),
        _PlanFeature('Unlimited mentor sessions', true),
        _PlanFeature('1-on-1 AI career coaching', true),
        _PlanFeature('Priority mentor matching', true),
        _PlanFeature('Priority support', true),
        _PlanFeature('Early access to features', true),
        _PlanFeature('UniLink Premium badge', true),
        _PlanFeature('Scholarship application review', true),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedPlan = _plans[_selectedPlanIndex];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // ─── Hero ──────────────────────────────────────
          SliverToBoxAdapter(
            child: _UpgradeHero(
              onBack: () => Navigator.pop(context),
            ),
          ),

          // ─── Billing toggle ────────────────────────────
          SliverToBoxAdapter(
            child: _BillingToggle(
              isAnnual: _isAnnual,
              onToggle: (v) => setState(() => _isAnnual = v),
            ).animate().fadeIn(delay: 200.ms),
          ),

          // ─── Plans ─────────────────────────────────────
          SliverToBoxAdapter(
            child: _PlanSelector(
              plans: _plans,
              selectedIndex: _selectedPlanIndex,
              isAnnual: _isAnnual,
              onSelect: (i) {
                HapticFeedback.selectionClick();
                setState(() => _selectedPlanIndex = i);
              },
            ).animate().fadeIn(delay: 300.ms),
          ),

          // ─── Features ──────────────────────────────────
          SliverToBoxAdapter(
            child: _FeatureList(
              plan: selectedPlan,
            ).animate().fadeIn(delay: 400.ms),
          ),

          // ─── Social proof ───────────────────────────────
          SliverToBoxAdapter(
            child: _SocialProof()
                .animate()
                .fadeIn(delay: 500.ms),
          ),

          // ─── CTA ───────────────────────────────────────
          SliverToBoxAdapter(
            child: _UpgradeCTA(
              plan: selectedPlan,
              isAnnual: _isAnnual,
            ).animate().fadeIn(delay: 600.ms),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
                height: MediaQuery.of(context).padding.bottom + 24),
          ),
        ],
      ),
    );
  }
}

// ─── Hero ─────────────────────────────────────────────────────────────────

class _UpgradeHero extends StatelessWidget {
  final VoidCallback onBack;

  const _UpgradeHero({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        36,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0B1D3A),
            Color(0xFF1A1040),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Background stars
          ...List.generate(8, (i) {
            return Positioned(
              top: (i * 37.0) % 160,
              left: (i * 53.0) % 300,
              child: Container(
                width: i % 3 == 0 ? 4 : 2,
                height: i % 3 == 0 ? 4 : 2,
                decoration: BoxDecoration(
                  color: Colors.white
                      .withOpacity(0.1 + (i % 4) * 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Crown
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppGradients.premium,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.premiumGold.withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('👑',
                      style: TextStyle(fontSize: 32)),
                ),
              )
                  .animate()
                  .scale(
                begin: const Offset(0.5, 0.5),
                duration: 600.ms,
                curve: Curves.elasticOut,
              )
                  .fadeIn(duration: 300.ms),

              const SizedBox(height: 16),

              Text(
                'Unlock Your\nFull Potential',
                style: AppTypography.displayL.copyWith(
                  color: AppColors.white,
                  height: 1.15,
                ),
              ).animate().fadeIn(delay: 150.ms),

              const SizedBox(height: 10),

              Text(
                'Join pro students getting better mentor matches, unlimited AI guidance, and exclusive scholarship access.',
                style: AppTypography.bodyM.copyWith(
                  color: AppColors.white.withOpacity(0.7),
                  height: 1.55,
                ),
              ).animate().fadeIn(delay: 250.ms),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Billing toggle ───────────────────────────────────────────────────────

class _BillingToggle extends StatelessWidget {
  final bool isAnnual;
  final ValueChanged<bool> onToggle;

  const _BillingToggle({
    required this.isAnnual,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 24,
          AppSpacing.screenPadding, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => onToggle(false),
            child: Text(
              'Monthly',
              style: AppTypography.labelL.copyWith(
                color: !isAnnual
                    ? AppColors.primaryBlue
                    : AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => onToggle(!isAnnual),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 52,
              height: 28,
              decoration: BoxDecoration(
                color: isAnnual
                    ? AppColors.primaryBlue
                    : AppColors.border,
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                alignment: isAnnual
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => onToggle(true),
            child: Row(
              children: [
                Text(
                  'Annual',
                  style: AppTypography.labelL.copyWith(
                    color: isAnnual
                        ? AppColors.primaryBlue
                        : AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Save 30%',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
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

// ─── Plan selector ────────────────────────────────────────────────────────

class _PlanSelector extends StatelessWidget {
  final List<_Plan> plans;
  final int selectedIndex;
  final bool isAnnual;
  final ValueChanged<int> onSelect;

  const _PlanSelector({
    required this.plans,
    required this.selectedIndex,
    required this.isAnnual,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 20,
          AppSpacing.screenPadding, 0),
      child: Row(
        children: plans.asMap().entries.map((e) {
          final index = e.key;
          final plan = e.value;
          final isSelected = index == selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.only(
                    right: index < plans.length - 1 ? 8 : 0),
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? plan.color.withOpacity(0.06)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? plan.color
                        : AppColors.borderLight,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: plan.color.withOpacity(0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : [],
                ),
                child: Column(
                  children: [
                    if (plan.isMostPopular)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: AppGradients.heroBlue,
                          borderRadius:
                          BorderRadius.circular(6),
                        ),
                        child: Text(
                          '⭐ Popular',
                          style: AppTypography.caption
                              .copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (plan.isMostPopular)
                      const SizedBox(height: 6),
                    Text(
                      plan.name,
                      style: AppTypography.h4.copyWith(
                        color: isSelected
                            ? plan.color
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.monthlyPrice == 0
                          ? 'Free'
                          : isAnnual
                          ? '\$${plan.annualPrice}/yr'
                          : '\$${plan.monthlyPrice}/mo',
                      style: AppTypography.bodyS.copyWith(
                        color: isSelected
                            ? plan.color
                            : AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Feature list ─────────────────────────────────────────────────────────

class _FeatureList extends StatelessWidget {
  final _Plan plan;

  const _FeatureList({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 24,
          AppSpacing.screenPadding, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${plan.name} includes:',
              style: AppTypography.h4,
            ),
            const SizedBox(height: 14),
            ...plan.features.map((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: feature.isIncluded
                            ? plan.color.withOpacity(0.1)
                            : AppColors.borderLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        feature.isIncluded
                            ? Icons.check_rounded
                            : Icons.close_rounded,
                        size: 13,
                        color: feature.isIncluded
                            ? plan.color
                            : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      feature.label,
                      style: AppTypography.bodyM.copyWith(
                        color: feature.isIncluded
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                        decoration: feature.isIncluded
                            ? null
                            : TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Social proof ─────────────────────────────────────────────────────────

class _SocialProof extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 20,
          AppSpacing.screenPadding, 0),
      child: Column(
        children: [
          // Testimonial
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color:
                  AppColors.primaryBlue.withOpacity(0.15)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('⭐⭐⭐⭐⭐',
                        style: TextStyle(fontSize: 16)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '✓ Verified',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '"UniLink Pro helped me get a full scholarship to UDSM. The AI coach guided my application perfectly and matched me with Dr. Sarah who reviewed my personal statement."',
                  style: AppTypography.bodyM.copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryBlue,
                      ),
                      child: const Center(
                        child: Text('F',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text('Fatuma Ally',
                            style: AppTypography.labelL),
                        Text(
                            'Form 6 Graduate → UDSM Medicine 2024',
                            style: AppTypography.caption),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Stats
          Row(
            children: [
              Expanded(
                  child: _SocialStat(
                      '2,400+', 'Active Users')),
              Expanded(
                  child:
                  _SocialStat('4.9★', 'App Rating')),
              Expanded(
                  child:
                  _SocialStat('94%', 'Success Rate')),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialStat extends StatelessWidget {
  final String value;
  final String label;

  const _SocialStat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.h2.copyWith(
              color: AppColors.primaryBlue),
        ),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}

// ─── Upgrade CTA ──────────────────────────────────────────────────────────

class _UpgradeCTA extends StatelessWidget {
  final _Plan plan;
  final bool isAnnual;

  const _UpgradeCTA({
    required this.plan,
    required this.isAnnual,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 24,
          AppSpacing.screenPadding, 0),
      child: Column(
        children: [
          // Main CTA
          PrimaryButton(
            label: plan.monthlyPrice == 0
                ? 'Continue with Free'
                : 'Start ${plan.name} — ${isAnnual ? '\$${plan.annualPrice}/year' : '\$${plan.monthlyPrice}/month'}',
            gradient: plan.id == 'free'
                ? null
                : LinearGradient(
              colors: [plan.color, plan.color.withOpacity(0.8)],
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              // TODO: Connect to payment provider
              // PaymentService.startCheckout(planId: plan.id, annual: isAnnual)
              Navigator.pop(context);
            },
            height: 56,
          ),

          const SizedBox(height: 12),

          // Annual savings note
          if (isAnnual && plan.monthlyPrice > 0)
            Text(
              'You save \$${((plan.monthlyPrice * 12) - plan.annualPrice)}  vs monthly billing',
              style: AppTypography.bodyS.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

          const SizedBox(height: 16),

          // Guarantee
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user_outlined,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 5),
              Text(
                '7-day money-back guarantee • Cancel anytime',
                style: AppTypography.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Data models (local) ──────────────────────────────────────────────────

class _Plan {
  final String id;
  final String name;
  final int monthlyPrice;
  final int annualPrice;
  final Color color;
  final String description;
  final bool isMostPopular;
  final List<_PlanFeature> features;

  const _Plan({
    required this.id,
    required this.name,
    required this.monthlyPrice,
    required this.annualPrice,
    required this.color,
    required this.description,
    this.isMostPopular = false,
    required this.features,
  });
}

class _PlanFeature {
  final String label;
  final bool isIncluded;

  const _PlanFeature(this.label, this.isIncluded);
}