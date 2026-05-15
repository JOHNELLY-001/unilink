import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_gradients.dart';

class AiQuickPrompts extends StatelessWidget {
  final void Function(String prompt) onPromptTap;

  const AiQuickPrompts({super.key, required this.onPromptTap});

  static const _prompts = [
    (
    '🎓',
    'Best universities for CS in Tanzania',
    'What are the best universities in Tanzania for Computer Science?',
    AppColors.primaryBlue,
    ),
    (
    '🤝',
    'Find me a mentor',
    'Help me find a mentor in software engineering',
    AppColors.accentTeal,
    ),
    (
    '💰',
    'Scholarships available',
    'What scholarships are available for Tanzanian students?',
    AppColors.premiumGold,
    ),
    (
    '🚀',
    'Career roadmap for me',
    'Create a career roadmap for software engineering from Form 6',
    AppColors.premiumPurple,
    ),
    (
    '💼',
    'Internships in Dar es Salaam',
    'What internships are available in Dar es Salaam for students?',
    AppColors.success,
    ),
    (
    '📊',
    'Salary expectations',
    'What are typical salaries for software engineers in Tanzania?',
    AppColors.error,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppGradients.heroNavy,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppGradients.heroBlue,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue
                              .withOpacity(0.5),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.smart_toy_rounded,
                        color: Colors.white, size: 22),
                  )
                      .animate(
                      onPlay: (c) =>
                          c.repeat(reverse: true))
                      .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.06, 1.06),
                    duration: 2000.ms,
                    curve: Curves.easeInOut,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'UniLink AI',
                          style: AppTypography.h3.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          'Your personal career guide for Tanzania',
                          style: AppTypography.bodyS.copyWith(
                            color: AppColors.white
                                .withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Ask me anything about careers, universities, scholarships, or mentors. I\'m here to guide your future. 🇹🇿',
                style: AppTypography.bodyM.copyWith(
                  color: AppColors.white.withOpacity(0.85),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(
          begin: 0.1,
          end: 0,
          duration: 500.ms,
          curve: Curves.easeOut,
        ),

        const SizedBox(height: 20),

        Text(
          'Try asking...',
          style: AppTypography.h4,
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 12),

        // Prompt grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.5,
          children: _prompts.asMap().entries.map((e) {
            final index = e.key;
            final prompt = e.value;
            return _PromptCard(
              emoji: prompt.$1,
              label: prompt.$2,
              fullPrompt: prompt.$3,
              color: prompt.$4,
              onTap: () {
                HapticFeedback.selectionClick();
                onPromptTap(prompt.$3);
              },
            )
                .animate()
                .fadeIn(
              delay: Duration(
                  milliseconds: 250 + 60 * index),
              duration: 400.ms,
            )
                .slideY(
              begin: 0.1,
              end: 0,
              delay: Duration(
                  milliseconds: 250 + 60 * index),
              duration: 400.ms,
              curve: Curves.easeOut,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PromptCard extends StatefulWidget {
  final String emoji;
  final String label;
  final String fullPrompt;
  final Color color;
  final VoidCallback onTap;

  const _PromptCard({
    required this.emoji,
    required this.label,
    required this.fullPrompt,
    required this.color,
    required this.onTap,
  });

  @override
  State<_PromptCard> createState() => _PromptCardState();
}

class _PromptCardState extends State<_PromptCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: widget.color.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.emoji,
                  style: const TextStyle(fontSize: 22)),
              const Spacer(),
              Text(
                widget.label,
                style: AppTypography.labelM.copyWith(
                  color: widget.color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}