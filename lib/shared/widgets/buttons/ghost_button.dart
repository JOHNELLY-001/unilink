import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final Color? color;
  final TextStyle? textStyle;

  const GhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.color,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primaryBlue;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: effectiveColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 16, color: effectiveColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: (textStyle ?? AppTypography.labelL)
                .copyWith(color: effectiveColor),
          ),
        ],
      ),
    );
  }
}