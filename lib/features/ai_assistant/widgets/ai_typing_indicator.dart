import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_gradients.dart';

class AiTypingIndicator extends StatefulWidget {
  const AiTypingIndicator({super.key});

  @override
  State<AiTypingIndicator> createState() =>
      _AiTypingIndicatorState();
}

class _AiTypingIndicatorState extends State<AiTypingIndicator>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      final animation = Tween<double>(begin: 0.0, end: 1.0)
          .animate(CurvedAnimation(
          parent: controller, curve: Curves.easeInOut));
      _controllers.add(controller);
      _animations.add(animation);

      // Stagger each dot
      Future.delayed(Duration(milliseconds: 150 * i), () {
        if (mounted) controller.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // AI avatar
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: AppGradients.heroBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.smart_toy_rounded,
                size: 14, color: Colors.white),
          ),
          const SizedBox(width: 8),

          // Typing bubble
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryNavy.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'UniLink AI is thinking',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 8),
                ...List.generate(3, (i) {
                  return AnimatedBuilder(
                    animation: _animations[i],
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, -4 * _animations[i].value),
                      child: Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(
                              0.4 + 0.6 * _animations[i].value),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}