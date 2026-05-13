import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_gradients.dart';

class PremiumBadge extends StatelessWidget {
  final String label;
  final bool small;

  const PremiumBadge({super.key, this.label = 'PRO', this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 7 : 10,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        gradient: AppGradients.premium,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded,
              size: small ? 10 : 12,
              color: AppColors.white),
          const SizedBox(width: 3),
          Text(
            label,
            style: (small ? AppTypography.caption : AppTypography.labelS)
                .copyWith(color: AppColors.white,
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Lock icon overlay for premium-gated features
class PremiumLockBadge extends StatelessWidget {
  const PremiumLockBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        gradient: AppGradients.premium,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.premiumGold.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.lock_rounded,
          size: 14, color: AppColors.white),
    );
  }
}