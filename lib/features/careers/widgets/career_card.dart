import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../models/career_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_shadows.dart';

// ─── Compact horizontal card (dashboard / explore) ────────────────────────

class CompactCareerCard extends StatefulWidget {
  final CareerModel career;
  final VoidCallback onTap;

  const CompactCareerCard({
    super.key,
    required this.career,
    required this.onTap,
  });

  @override
  State<CompactCareerCard> createState() => _CompactCareerCardState();
}

class _CompactCareerCardState extends State<CompactCareerCard> {
  bool _pressed = false;

  Color get _cardColor => Color(
      int.parse(widget.career.colorHex.replaceFirst('#', '0xFF')));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_cardColor, _cardColor.withOpacity(0.75)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _cardColor.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji + save indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.career.emoji,
                      style: const TextStyle(fontSize: 28)),
                  if (widget.career.isTrending)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '🔥',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                widget.career.title,
                style: AppTypography.h4.copyWith(
                  color: AppColors.white,
                  height: 1.2,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 6),
              // Salary range pill
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.career.salaryInsight.entryDisplay,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Full list career card (careers screen) ───────────────────────────────

class CareerListCard extends StatefulWidget {
  final CareerModel career;
  final VoidCallback onTap;
  final VoidCallback? onSave;

  const CareerListCard({
    super.key,
    required this.career,
    required this.onTap,
    this.onSave,
  });

  @override
  State<CareerListCard> createState() => _CareerListCardState();
}

class _CareerListCardState extends State<CareerListCard> {
  bool _pressed = false;

  Color get _cardColor => Color(
      int.parse(widget.career.colorHex.replaceFirst('#', '0xFF')));

  @override
  Widget build(BuildContext context) {
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
            border: Border.all(color: AppColors.borderLight),
            boxShadow: AppShadows.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Card header (gradient) ────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _cardColor.withOpacity(0.12),
                      _cardColor.withOpacity(0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: Row(
                  children: [
                    // Icon container
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_cardColor, _cardColor.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _cardColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(widget.career.emoji,
                            style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.career.title,
                                  style: AppTypography.h3,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.career.isTrending)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.errorLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('🔥 Hot',
                                      style: AppTypography.caption.copyWith(
                                          color: AppColors.error,
                                          fontWeight: FontWeight.w700)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.career.category,
                            style: AppTypography.caption.copyWith(
                              color: _cardColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Save button
                    GestureDetector(
                      onTap: widget.onSave,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: widget.career.isSaved
                              ? _cardColor.withOpacity(0.12)
                              : AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          widget.career.isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_outline_rounded,
                          size: 18,
                          color: widget.career.isSaved
                              ? _cardColor
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Card body ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.career.shortDescription,
                      style: AppTypography.bodyS,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Salary + demand row
                    Row(
                      children: [
                        _InfoPill(
                          icon: Icons.payments_outlined,
                          label: widget.career.salaryInsight.entryDisplay,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        _DemandPill(level: widget.career.demandLevel),
                        const SizedBox(width: 8),
                        _GrowthPill(level: widget.career.growthOutlook),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Skills preview
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.career.requiredSkills
                          .take(3)
                          .map(
                            (skill) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(skill,
                              style: AppTypography.caption),
                        ),
                      )
                          .toList(),
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

// ─── Supporting pill widgets ──────────────────────────────────────────────

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: AppTypography.caption.copyWith(
                  color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _DemandPill extends StatelessWidget {
  final String level;

  const _DemandPill({required this.level});

  @override
  Widget build(BuildContext context) {
    final isHigh = level == 'high';
    final color = isHigh ? AppColors.primaryBlue : AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isHigh ? '📈 High demand' : '📊 Medium demand',
        style: AppTypography.caption
            .copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _GrowthPill extends StatelessWidget {
  final String level;

  const _GrowthPill({required this.level});

  @override
  Widget build(BuildContext context) {
    if (level != 'high') return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentTeal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '🚀 Growing',
        style: AppTypography.caption.copyWith(
            color: AppColors.accentTeal, fontWeight: FontWeight.w600),
      ),
    );
  }
}