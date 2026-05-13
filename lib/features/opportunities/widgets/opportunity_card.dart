import 'package:flutter/material.dart';
import '../../../models/opportunity_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_shadows.dart';

// ─── Full list card ───────────────────────────────────────────────────────

class OpportunityListCard extends StatefulWidget {
  final OpportunityModel opportunity;
  final VoidCallback onTap;
  final VoidCallback? onBookmark;

  const OpportunityListCard({
    super.key,
    required this.opportunity,
    required this.onTap,
    this.onBookmark,
  });

  @override
  State<OpportunityListCard> createState() =>
      _OpportunityListCardState();
}

class _OpportunityListCardState extends State<OpportunityListCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final opp = widget.opportunity;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: opp.isDeadlineSoon
                  ? AppColors.warning.withOpacity(0.4)
                  : opp.isFeatured
                  ? AppColors.primaryBlue.withOpacity(0.3)
                  : AppColors.borderLight,
            ),
            boxShadow: AppShadows.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ─────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: opp.isFeatured
                      ? AppColors.primaryBlue.withOpacity(0.04)
                      : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type emoji container
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          opp.type.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  opp.title,
                                  style: AppTypography.h4,
                                  maxLines: 2,
                                  overflow:
                                  TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: widget.onBookmark,
                                child: AnimatedContainer(
                                  duration: const Duration(
                                      milliseconds: 200),
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: opp.isBookmarked
                                        ? AppColors.primaryBlue
                                        .withOpacity(0.1)
                                        : AppColors.surfaceMuted,
                                    borderRadius:
                                    BorderRadius.circular(
                                        10),
                                  ),
                                  child: Icon(
                                    opp.isBookmarked
                                        ? Icons.bookmark_rounded
                                        : Icons
                                        .bookmark_outline_rounded,
                                    size: 17,
                                    color: opp.isBookmarked
                                        ? AppColors.primaryBlue
                                        : AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            opp.organization,
                            style: AppTypography.bodyS.copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Body ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    16, 0, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opp.shortDescription,
                      style: AppTypography.bodyS,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Meta row
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _MetaPill(
                          icon: Icons.category_rounded,
                          label: opp.type.displayName,
                          color: AppColors.primaryBlue,
                        ),
                        _MetaPill(
                          icon: Icons.location_on_rounded,
                          label: opp.isRemote
                              ? 'Remote'
                              : opp.location,
                          color: AppColors.textSecondary,
                        ),
                        if (opp.fundingAmount != null)
                          _MetaPill(
                            icon: Icons.payments_rounded,
                            label: opp.fundingAmount!,
                            color: AppColors.success,
                          ),
                        if (opp.stipendAmount != null &&
                            opp.fundingAmount == null)
                          _MetaPill(
                            icon: Icons.payments_rounded,
                            label: opp.stipendAmount!,
                            color: AppColors.accentTeal,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Deadline row
                    Row(
                      children: [
                        _DeadlineBadge(opportunity: opp),
                        const Spacer(),
                        if (opp.isRecommended)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.premiumGoldLight,
                              borderRadius:
                              BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 12,
                                  color: AppColors.premiumGold,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Recommended',
                                  style: AppTypography.caption
                                      .copyWith(
                                    color: AppColors.premiumGold,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Compact card used in explore / dashboard ─────────────────────────────

class CompactOpportunityCard extends StatelessWidget {
  final OpportunityModel opportunity;
  final VoidCallback onTap;

  const CompactOpportunityCard({
    super.key,
    required this.opportunity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: opportunity.isDeadlineSoon
                ? AppColors.warning.withOpacity(0.4)
                : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  opportunity.type.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opportunity.title,
                    style: AppTypography.labelL,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    opportunity.organization,
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            if (opportunity.isDeadlineSoon)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${opportunity.daysUntilDeadline}d left',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Supporting widgets ───────────────────────────────────────────────────

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.caption
                .copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _DeadlineBadge extends StatelessWidget {
  final OpportunityModel opportunity;

  const _DeadlineBadge({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    if (opportunity.isExpired) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event_busy_rounded,
              size: 13, color: AppColors.error),
          const SizedBox(width: 4),
          Text('Expired',
              style: AppTypography.caption
                  .copyWith(color: AppColors.error)),
        ],
      );
    }
    final days = opportunity.daysUntilDeadline;
    final isUrgent = days <= 3;
    final color = isUrgent ? AppColors.error : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            days == 0
                ? 'Closes today!'
                : '$days day${days != 1 ? 's' : ''} left',
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}