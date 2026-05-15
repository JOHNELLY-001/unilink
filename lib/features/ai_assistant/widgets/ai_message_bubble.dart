import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../models/ai_message_model.dart';
import '../../ai_assistant/widgets/ai_typing_indicator.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_gradients.dart';
import '../../../routes/app_routes.dart';
import 'package:go_router/go_router.dart';

// ─── AI message bubble ────────────────────────────────────────────────────

class AiMessageBubble extends StatelessWidget {
  final AiMessageModel message;
  final void Function(String route, String id)? onActionTap;
  final void Function(String prompt)? onSuggestionTap;

  const AiMessageBubble({
    super.key,
    required this.message,
    this.onActionTap,
    this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isLoading) return const AiTypingIndicator();

    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(
        bottom: 14,
        left: isUser ? 48 : 0,
        right: isUser ? 0 : 48,
      ),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // ─── Sender label ─────────────────────────────
          if (!isUser) ...[
            Row(
              children: [
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
                const SizedBox(width: 6),
                Text(
                  'UniLink AI',
                  style: AppTypography.labelS.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],

          // ─── Bubble ───────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isUser ? AppGradients.heroBlue : null,
              color: isUser ? null : AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft:
                Radius.circular(isUser ? 18 : 4),
                bottomRight:
                Radius.circular(isUser ? 4 : 18),
              ),
              border: isUser
                  ? null
                  : Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color:
                  AppColors.primaryNavy.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _AiBubbleContent(
              message: message,
              isUser: isUser,
            ),
          ),

          // ─── Action cards ─────────────────────────────
          if (!isUser &&
              message.actionCards != null &&
              message.actionCards!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ActionCardsRow(
              cards: message.actionCards!,
              onTap: onActionTap,
            ),
          ],

          // ─── Suggestion chips ─────────────────────────
          if (!isUser &&
              message.suggestions != null &&
              message.suggestions!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _SuggestionChipsRow(
              chips: message.suggestions!,
              onTap: onSuggestionTap,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Bubble content (handles markdown-style bold text) ────────────────────

class _AiBubbleContent extends StatelessWidget {
  final AiMessageModel message;
  final bool isUser;

  const _AiBubbleContent({
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(
            ClipboardData(text: message.content));
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Copied to clipboard'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    // Parse simple markdown: **bold**, bullet points
    final lines = message.content.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        if (i < lines.length - 1) {
          widgets.add(const SizedBox(height: 6));
        }
        continue;
      }

      // Bullet point lines
      if (line.startsWith('•') || line.startsWith('-')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: AppTypography.bodyM.copyWith(
                  color: isUser
                      ? AppColors.white
                      : AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: _parseInline(
                  line.replaceFirst(RegExp(r'^[•\-]\s*'), ''),
                  isUser,
                ),
              ),
            ],
          ),
        ));
        continue;
      }

      // Numbered lines
      final numberedMatch =
      RegExp(r'^\d+\.\s').firstMatch(line);
      if (numberedMatch != null) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                numberedMatch.group(0) ?? '',
                style: AppTypography.bodyM.copyWith(
                  color: isUser
                      ? AppColors.white
                      : AppColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: _parseInline(
                  line.substring(numberedMatch.end),
                  isUser,
                ),
              ),
            ],
          ),
        ));
        continue;
      }

      // Table header separator — skip
      if (line.startsWith('|---')) continue;

      // Table rows
      if (line.startsWith('|') && line.endsWith('|')) {
        final cells = line
            .split('|')
            .where((s) => s.trim().isNotEmpty)
            .toList();
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            children: cells.map((cell) {
              return Expanded(
                child: Text(
                  cell.trim(),
                  style: AppTypography.bodyS.copyWith(
                    color: isUser
                        ? AppColors.white.withOpacity(0.9)
                        : AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        ));
        continue;
      }

      // Normal text
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: _parseInline(line, isUser),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _parseInline(String text, bool isUser) {
    // Parse **bold** segments
    final spans = <InlineSpan>[];
    final boldRegex = RegExp(r'\*\*(.+?)\*\*');
    int lastIndex = 0;

    for (final match in boldRegex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: AppTypography.bodyM.copyWith(
            color: isUser
                ? AppColors.white.withOpacity(0.95)
                : AppColors.textPrimary,
            height: 1.5,
          ),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: AppTypography.bodyM.copyWith(
          color: isUser
              ? AppColors.white
              : AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: AppTypography.bodyM.copyWith(
          color: isUser
              ? AppColors.white.withOpacity(0.95)
              : AppColors.textPrimary,
          height: 1.5,
        ),
      ));
    }

    if (spans.isEmpty) {
      return Text(
        text,
        style: AppTypography.bodyM.copyWith(
          color: isUser
              ? AppColors.white.withOpacity(0.95)
              : AppColors.textPrimary,
          height: 1.5,
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }
}

// ─── Action cards row ─────────────────────────────────────────────────────

class _ActionCardsRow extends StatelessWidget {
  final List<AiActionCard> cards;
  final void Function(String route, String id)? onTap;

  const _ActionCardsRow({required this.cards, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final card = cards[index];
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              // Route to appropriate screen
              switch (card.actionType) {
                case 'view_mentor':
                  context.push(
                      AppRoutes.mentorDetailPath(card.actionTargetId));
                  break;
                case 'view_career':
                  context.push(
                      AppRoutes.careerDetailPath(card.actionTargetId));
                  break;
                case 'view_opportunity':
                  context.push(AppRoutes.opportunityDetailPath(
                      card.actionTargetId));
                  break;
                default:
                  onTap?.call(card.actionType, card.actionTargetId);
              }
            },
            child: Container(
              width: 190,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primaryBlue.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color:
                    AppColors.primaryBlue.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(card.emoji,
                      style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Text(
                          card.title,
                          style: AppTypography.labelM,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          card.subtitle,
                          style: AppTypography.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: AppColors.primaryBlue),
                ],
              ),
            )
                .animate()
                .fadeIn(
              delay: Duration(milliseconds: 80 * index),
              duration: 300.ms,
            )
                .slideX(
              begin: 0.05,
              end: 0,
              delay: Duration(milliseconds: 80 * index),
              duration: 300.ms,
            ),
          );
        },
      ),
    );
  }
}

// ─── Suggestion chips row ─────────────────────────────────────────────────

class _SuggestionChipsRow extends StatelessWidget {
  final List<AiSuggestionChip> chips;
  final void Function(String prompt)? onTap;

  const _SuggestionChipsRow({required this.chips, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips.asMap().entries.map((e) {
        final chip = e.value;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap?.call(chip.prompt);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.2)),
            ),
            child: Text(
              chip.label,
              style: AppTypography.labelS.copyWith(
                color: AppColors.primaryBlue,
              ),
            ),
          )
              .animate()
              .fadeIn(
            delay: Duration(milliseconds: 60 * e.key),
            duration: 300.ms,
          ),
        );
      }).toList(),
    );
  }
}