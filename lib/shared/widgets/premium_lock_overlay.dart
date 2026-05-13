import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_gradients.dart';
import 'dialogs/upgrade_dialog.dart';

/// Wraps any widget and applies a blur + lock overlay for premium features.
/// Usage: wrap any widget — the upgrade dialog fires on tap.
class PremiumLockOverlay extends StatelessWidget {
  final Widget child;
  final String featureName;
  final String description;
  final bool isLocked;

  const PremiumLockOverlay({
    super.key,
    required this.child,
    required this.featureName,
    this.description = 'Upgrade to UniLink Pro to unlock this feature.',
    this.isLocked = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLocked) return child;

    return Stack(
      children: [
        // Blurred content underneath
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: IgnorePointer(child: child),
        ),

        // Lock overlay
        Positioned.fill(
          child: GestureDetector(
            onTap: () => UpgradeDialog.show(
              context,
              featureName: featureName,
              description: description,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppGradients.premium,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.premiumGold.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.lock_rounded,
                          color: AppColors.white, size: 22),
                    ),
                    const SizedBox(height: 10),
                    Text('Pro Feature',
                        style: AppTypography.labelL.copyWith(
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text('Tap to unlock',
                        style: AppTypography.caption),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}