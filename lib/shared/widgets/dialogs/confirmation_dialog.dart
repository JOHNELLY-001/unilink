import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../buttons/primary_button.dart';
import '../buttons/ghost_button.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
  });

  static Future<bool?> show(
      BuildContext context, {
        required String title,
        required String message,
        String confirmLabel = 'Confirm',
        String cancelLabel = 'Cancel',
        bool isDestructive = false,
      }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.pop(ctx, true),
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
            if (isDestructive)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: AppColors.error, size: 28),
              ),
            if (isDestructive) const SizedBox(height: 16),
            Text(title,
                style: AppTypography.h2, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message,
                style: AppTypography.bodyM, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            PrimaryButton(
              label: confirmLabel,
              gradient: isDestructive
                  ? LinearGradient(colors: [
                AppColors.error,
                AppColors.error.withOpacity(0.85),
              ])
                  : null,
              onPressed: onConfirm,
            ),
            const SizedBox(height: 12),
            GhostButton(
              label: cancelLabel,
              color: AppColors.textMuted,
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        ),
      ),
    );
  }
}