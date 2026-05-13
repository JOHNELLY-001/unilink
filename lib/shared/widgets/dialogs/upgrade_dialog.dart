import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_gradients.dart';
import '../../../routes/app_routes.dart';
import '../buttons/primary_button.dart';
import '../buttons/ghost_button.dart';

class UpgradeDialog extends StatelessWidget {
  final String featureName;
  final String description;

  const UpgradeDialog({
    super.key,
    required this.featureName,
    required this.description,
  });

  static Future<void> show(
      BuildContext context, {
        required String featureName,
        required String description,
      }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => UpgradeDialog(
        featureName: featureName,
        description: description,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: AppGradients.premium,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: AppColors.white, size: 30),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Unlock $featureName',
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              description,
              style: AppTypography.bodyM,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Benefits
            _BenefitRow(
                icon: Icons.smart_toy_rounded,
                label: 'Unlimited AI conversations'),
            const SizedBox(height: 8),
            _BenefitRow(
                icon: Icons.calendar_month_rounded,
                label: 'Unlimited mentor sessions'),
            const SizedBox(height: 8),
            _BenefitRow(
                icon: Icons.tune_rounded,
                label: 'Advanced filters & insights'),
            const SizedBox(height: 24),

            // CTA
            PrimaryButton(
              label: 'Upgrade to Pro',
              gradient: AppGradients.premium,
              onPressed: () {
                Navigator.pop(context);
                context.push(AppRoutes.upgrade);
              },
            ),
            const SizedBox(height: 12),
            GhostButton(
              label: 'Maybe later',
              color: AppColors.textMuted,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BenefitRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.premiumGoldLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              size: 16, color: AppColors.premiumGold),
        ),
        const SizedBox(width: 12),
        Text(label, style: AppTypography.bodyS.copyWith(
            color: AppColors.textPrimary)),
      ],
    );
  }
}