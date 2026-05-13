import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_gradients.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showLogo;
  final bool darkBackground;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showLogo = true,
    this.darkBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.of(context).padding.top + 24,
        24,
        36,
      ),
      decoration: darkBackground
          ? const BoxDecoration(gradient: AppGradients.heroNavy)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLogo) ...[
            _LogoPill(dark: darkBackground)
                .animate()
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 28),
          ],
          Text(
            title,
            style: AppTypography.displayM.copyWith(
              color: darkBackground
                  ? AppColors.white
                  : AppColors.textPrimary,
              height: 1.2,
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 500.ms)
              .slideY(
            begin: 0.2,
            end: 0,
            delay: 100.ms,
            duration: 500.ms,
            curve: Curves.easeOut,
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: AppTypography.bodyM.copyWith(
              color: darkBackground
                  ? AppColors.white.withOpacity(0.7)
                  : AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
        ],
      ),
    );
  }
}

class _LogoPill extends StatelessWidget {
  final bool dark;
  const _LogoPill({required this.dark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withOpacity(0.12)
            : AppColors.primaryBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: dark
              ? Colors.white.withOpacity(0.2)
              : AppColors.primaryBlue.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.accentTeal],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.link_rounded,
                color: Colors.white, size: 13),
          ),
          const SizedBox(width: 7),
          Text(
            'UniLink',
            style: AppTypography.labelM.copyWith(
              color: dark ? AppColors.white : AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}