import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_spacing.dart';

class QuickActionsBar extends StatelessWidget {
  final VoidCallback onCareersTap;
  final VoidCallback onMentorsTap;
  final VoidCallback onOpportunitiesTap;
  final VoidCallback onAiTap;

  const QuickActionsBar({
    super.key,
    required this.onCareersTap,
    required this.onMentorsTap,
    required this.onOpportunitiesTap,
    required this.onAiTap,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action(Icons.work_rounded, 'Careers',
          AppColors.primaryBlue, onCareersTap),
      _Action(Icons.people_rounded, 'Mentors',
          AppColors.accentTeal, onMentorsTap),
      _Action(Icons.stars_rounded, 'Opportunities',
          AppColors.premiumGold, onOpportunitiesTap),
      _Action(Icons.smart_toy_rounded, 'Ask AI',
          AppColors.premiumPurple, onAiTap),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 20,
          AppSpacing.screenPadding, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions
            .map((a) => _QuickActionItem(action: a))
            .toList(),
      ),
    );
  }
}

class _Action {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _Action(this.icon, this.label, this.color, this.onTap);
}

class _QuickActionItem extends StatefulWidget {
  final _Action action;

  const _QuickActionItem({required this.action});

  @override
  State<_QuickActionItem> createState() => _QuickActionItemState();
}

class _QuickActionItemState extends State<_QuickActionItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.action.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: widget.action.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: widget.action.color.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                widget.action.icon,
                color: widget.action.color,
                size: 26,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              widget.action.label,
              style: AppTypography.labelS.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}