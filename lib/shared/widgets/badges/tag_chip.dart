import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class TagChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool isSelected;
  final IconData? icon;
  final bool small;

  const TagChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.isSelected = false,
    this.icon,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isSelected
        ? AppColors.primaryBlue
        : (backgroundColor ?? AppColors.surfaceMuted);
    final fg = isSelected
        ? AppColors.white
        : (textColor ?? AppColors.textSecondary);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: small ? 10 : 12,
          vertical: small ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: small ? 12 : 14, color: fg),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: (small
                  ? AppTypography.caption
                  : AppTypography.labelM)
                  .copyWith(color: fg),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontally scrollable row of filter chips
class FilterChipRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  final EdgeInsets? padding;

  const FilterChipRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: options.map((option) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TagChip(
              label: option,
              isSelected: selected == option,
              onTap: () => onSelected(option),
            ),
          );
        }).toList(),
      ),
    );
  }
}