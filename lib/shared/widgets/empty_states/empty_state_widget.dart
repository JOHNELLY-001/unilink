import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../buttons/primary_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final String emoji;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.emoji = '🔍',
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 56))
                .animate()
                .scale(begin: const Offset(0.5, 0.5), duration: 400.ms,
                curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text(title,
                style: AppTypography.h2, textAlign: TextAlign.center)
                .animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 8),
            Text(message,
                style: AppTypography.bodyM, textAlign: TextAlign.center)
                .animate().fadeIn(delay: 200.ms),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
                width: 200,
                height: 48,
              ).animate().fadeIn(delay: 300.ms),
            ],
          ],
        ),
      ),
    );
  }
}