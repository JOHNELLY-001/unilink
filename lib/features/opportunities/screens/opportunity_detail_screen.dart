import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/opportunity_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_spacing.dart';
import '../../../providers/opportunity_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../../shared/widgets/loaders/app_loader.dart';
import '../../../shared/widgets/empty_states/empty_state_widget.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/secondary_button.dart';

class OpportunityDetailScreen extends ConsumerWidget {
  final String opportunityId;

  const OpportunityDetailScreen({
    super.key,
    required this.opportunityId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oppAsync =
    ref.watch(opportunityDetailProvider(opportunityId));

    return oppAsync.when(
      loading: () => const Scaffold(
        body: AppLoader(message: 'Loading...'),
      ),
      error: (_, __) => Scaffold(
        body: EmptyStateWidget(
          title: 'Could not load opportunity',
          message: 'Please try again.',
          emoji: '😕',
          actionLabel: 'Go Back',
          onAction: () => context.pop(),
        ),
      ),
      data: (opp) {
        if (opp == null) {
          return Scaffold(
            body: EmptyStateWidget(
              title: 'Not found',
              message: 'This opportunity does not exist.',
              emoji: '🔍',
              actionLabel: 'Go Back',
              onAction: () => context.pop(),
            ),
          );
        }
        return _OpportunityDetailBody(
          opportunity: opp,
          onBookmark: () async {
            HapticFeedback.selectionClick();
            await ref
                .read(opportunityRepositoryProvider)
                .toggleBookmark(
              userId: 'usr_001',
              opportunityId: opp.id,
            );
            ref.invalidate(
                opportunityDetailProvider(opportunityId));
          },
          onApply: () async {
            HapticFeedback.mediumImpact();
            await ref
                .read(opportunityRepositoryProvider)
                .markAsApplied(
              userId: 'usr_001',
              opportunityId: opp.id,
            );
            ref.invalidate(
                opportunityDetailProvider(opportunityId));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                      '✅ Application marked! Good luck!'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          },
        );
      },
    );
  }
}

// ─── Detail body ──────────────────────────────────────────────────────────

class _OpportunityDetailBody extends StatelessWidget {
  final OpportunityModel opportunity;
  final VoidCallback onBookmark;
  final VoidCallback onApply;

  const _OpportunityDetailBody({
    required this.opportunity,
    required this.onBookmark,
    required this.onApply,
  });

  Color get _typeColor {
    switch (opportunity.type.name) {
      case 'scholarship':
        return AppColors.premiumGold;
      case 'internship':
        return AppColors.primaryBlue;
      case 'bootcamp':
        return AppColors.premiumPurple;
      case 'competition':
        return AppColors.error;
      default:
        return AppColors.accentTeal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // ─── Hero ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            elevation: 0,
            backgroundColor: _typeColor,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                    size: 18),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: onBookmark,
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
                        ScaleTransition(
                            scale: animation, child: child),
                    child: Icon(
                      opportunity.isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      key: ValueKey(opportunity.isBookmarked),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _HeroSection(
                opportunity: opportunity,
                typeColor: _typeColor,
              ),
            ),
          ),

          // ─── Content ───────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(
                AppSpacing.screenPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Status banner
                if (opportunity.isDeadlineSoon ||
                    opportunity.isExpired)
                  _StatusBanner(opportunity: opportunity)
                      .animate()
                      .fadeIn(delay: 100.ms),

                if (opportunity.isDeadlineSoon ||
                    opportunity.isExpired)
                  const SizedBox(height: 16),

                // Quick stats
                _QuickStats(opportunity: opportunity)
                    .animate()
                    .fadeIn(delay: 150.ms),

                const SizedBox(height: 20),

                // About section
                _DetailSection(
                  title: 'About this Opportunity',
                  child: Text(opportunity.description,
                      style: AppTypography.bodyM),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 16),

                // Eligibility
                if (opportunity.eligibility.isNotEmpty)
                  _DetailSection(
                    title: '✅ Eligibility Requirements',
                    child: Column(
                      children: opportunity.eligibility
                          .map((req) => _BulletRow(text: req))
                          .toList(),
                    ),
                  ).animate().fadeIn(delay: 250.ms),

                if (opportunity.eligibility.isNotEmpty)
                  const SizedBox(height: 16),

                // Benefits
                if (opportunity.benefits.isNotEmpty)
                  _DetailSection(
                    title: '🎁 Benefits',
                    child: Column(
                      children: opportunity.benefits
                          .map((b) => _BulletRow(
                          text: b, color: AppColors.success))
                          .toList(),
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                if (opportunity.benefits.isNotEmpty)
                  const SizedBox(height: 16),

                // Funding
                if (opportunity.fundingAmount != null ||
                    opportunity.stipendAmount != null)
                  _FundingCard(opportunity: opportunity)
                      .animate()
                      .fadeIn(delay: 350.ms),

                if (opportunity.fundingAmount != null ||
                    opportunity.stipendAmount != null)
                  const SizedBox(height: 16),

                // Required documents
                if (opportunity.requiredDocuments.isNotEmpty)
                  _DetailSection(
                    title: '📄 Required Documents',
                    child: Column(
                      children: opportunity.requiredDocuments
                          .asMap()
                          .entries
                          .map((e) => Padding(
                        padding: const EdgeInsets.only(
                            bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: AppColors
                                    .primaryBlue
                                    .withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${e.key + 1}',
                                  style: AppTypography
                                      .caption
                                      .copyWith(
                                    color: AppColors
                                        .primaryBlue,
                                    fontWeight:
                                    FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(e.value,
                                    style: AppTypography
                                        .bodyM)),
                          ],
                        ),
                      ))
                          .toList(),
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),

      // ─── Bottom CTA ───────────────────────────────
      bottomNavigationBar: _BottomCTA(
        opportunity: opportunity,
        typeColor: _typeColor,
        onApply: onApply,
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final OpportunityModel opportunity;
  final Color typeColor;

  const _HeroSection({
    required this.opportunity,
    required this.typeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [typeColor, typeColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
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
          SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(opportunity.type.emoji,
                      style: const TextStyle(fontSize: 40))
                      .animate()
                      .scale(
                    begin: const Offset(0.5, 0.5),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    opportunity.title,
                    style: AppTypography.h2.copyWith(
                        color: AppColors.white),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 4),
                  Text(
                    opportunity.organization,
                    style: AppTypography.bodyM.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ).animate().fadeIn(delay: 150.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final OpportunityModel opportunity;

  const _StatusBanner({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final isExpired = opportunity.isExpired;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isExpired
            ? AppColors.errorLight
            : AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpired
              ? AppColors.error.withOpacity(0.3)
              : AppColors.warning.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isExpired
                ? Icons.cancel_outlined
                : Icons.warning_amber_rounded,
            size: 18,
            color: isExpired ? AppColors.error : AppColors.warning,
          ),
          const SizedBox(width: 10),
          Text(
            isExpired
                ? 'This opportunity has closed'
                : '⏰ Closes in ${opportunity.daysUntilDeadline} day${opportunity.daysUntilDeadline != 1 ? 's' : ''}! Apply now.',
            style: AppTypography.labelM.copyWith(
              color: isExpired
                  ? AppColors.error
                  : const Color(0xFF92400E),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final OpportunityModel opportunity;

  const _QuickStats({required this.opportunity});

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.calendar_today_rounded,
              label: 'Deadline',
              value: _formatDate(opportunity.deadline),
            ),
          ),
          Container(
              width: 1, height: 40, color: AppColors.borderLight),
          Expanded(
            child: _StatItem(
              icon: opportunity.isRemote
                  ? Icons.language_rounded
                  : Icons.location_on_rounded,
              label: 'Location',
              value: opportunity.isRemote
                  ? 'Remote'
                  : opportunity.location.split(',').first,
            ),
          ),
          Container(
              width: 1, height: 40, color: AppColors.borderLight),
          Expanded(
            child: _StatItem(
              icon: Icons.people_rounded,
              label: 'Applicants',
              value: '${opportunity.applicationCount}+',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryBlue),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.labelM,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(label,
            style: AppTypography.caption,
            textAlign: TextAlign.center),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _DetailSection(
      {required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
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

class _BulletRow extends StatelessWidget {
  final String text;
  final Color color;

  const _BulletRow({
    required this.text,
    this.color = AppColors.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text, style: AppTypography.bodyM)),
        ],
      ),
    );
  }
}

class _FundingCard extends StatelessWidget {
  final OpportunityModel opportunity;

  const _FundingCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.premiumGold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.premiumGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.payments_rounded,
                size: 22, color: AppColors.premiumGold),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (opportunity.fundingAmount != null)
                  Text(opportunity.fundingAmount!,
                      style: AppTypography.h3.copyWith(
                          color: AppColors.premiumGold)),
                if (opportunity.stipendAmount != null)
                  Text(
                    'Stipend: ${opportunity.stipendAmount}',
                    style: AppTypography.bodyS,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomCTA extends StatelessWidget {
  final OpportunityModel opportunity;
  final Color typeColor;
  final VoidCallback onApply;

  const _BottomCTA({
    required this.opportunity,
    required this.typeColor,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final hasApplied =
        opportunity.applicationStatus == 'applied';

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
      child: hasApplied
          ? Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.success.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 20),
            const SizedBox(width: 8),
            Text(
              'Application tracked! ✅',
              style: AppTypography.labelL.copyWith(
                  color: AppColors.success),
            ),
          ],
        ),
      )
          : Row(
        children: [
          // Share
          SecondaryButton(
            label: 'Share',
            leadingIcon: Icons.ios_share_rounded,
            onPressed: () {},
            width: 110,
            height: 50,
            borderColor: typeColor,
            textColor: typeColor,
          ),
          const SizedBox(width: 12),
          // Apply
          Expanded(
            child: PrimaryButton(
              label: opportunity.isExpired
                  ? 'Closed'
                  : 'Apply Now',
              isDisabled: opportunity.isExpired,
              gradient: opportunity.isExpired
                  ? null
                  : LinearGradient(
                colors: [
                  typeColor,
                  typeColor.withOpacity(0.8),
                ],
              ),
              onPressed: opportunity.isExpired
                  ? null
                  : onApply,
              height: 50,
            ),
          ),
        ],
      ),
    );
  }
}