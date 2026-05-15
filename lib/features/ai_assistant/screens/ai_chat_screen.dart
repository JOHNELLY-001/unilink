import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_gradients.dart';
import '../../../theme/app_spacing.dart';
import '../../../providers/ai_provider.dart';
import '../../../routes/app_routes.dart';
import '../widgets/ai_message_bubble.dart';
import '../widgets/ai_quick_prompts.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() =>
      _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  bool _hasText = false;
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(() {
      final hasText = _inputController.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
    _scrollController.addListener(() {
      final show = _scrollController.offset > 200;
      if (show != _showScrollToBottom) {
        setState(() => _showScrollToBottom = show);
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage([String? overrideText]) async {
    final text =
        overrideText ?? _inputController.text.trim();
    if (text.isEmpty) return;

    _inputController.clear();
    _focusNode.unfocus();
    setState(() => _hasText = false);
    HapticFeedback.lightImpact();

    await ref.read(aiChatProvider.notifier).sendMessage(text);
    _scrollToTop();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatProvider);
    final messages = chatState.messages;
    final isEmpty = messages.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // ─── App bar ────────────────────────────────────
          _AiAppBar(
            onClear: messages.isNotEmpty
                ? () => ref
                .read(aiChatProvider.notifier)
                .clearHistory()
                : null,
            onVoice: () =>
                context.push(AppRoutes.aiVoice),
          ),

          // ─── Messages or welcome ────────────────────────
          Expanded(
            child: Stack(
              children: [
                // Content
                isEmpty
                    ? _WelcomeView(
                    onPromptTap: _sendMessage)
                    : _MessagesView(
                  messages: messages,
                  scrollController: _scrollController,
                  isTyping: chatState.isTyping,
                  onActionTap: (route, id) {},
                  onSuggestionTap: _sendMessage,
                ),

                // Scroll to bottom FAB
                if (_showScrollToBottom && !isEmpty)
                  Positioned(
                    bottom: 10,
                    right: 16,
                    child: GestureDetector(
                      onTap: _scrollToTop,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue
                                  .withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ).animate().scale(
                      begin: const Offset(0, 0),
                      duration: 200.ms,
                      curve: Curves.elasticOut,
                    ),
                  ),
              ],
            ),
          ),

          // ─── Input bar ──────────────────────────────────
          _AiInputBar(
            controller: _inputController,
            focusNode: _focusNode,
            hasText: _hasText,
            isTyping: chatState.isTyping,
            onSend: _sendMessage,
            onVoice: () => context.push(AppRoutes.aiVoice),
          ),
        ],
      ),
    );
  }
}

// ─── App bar ──────────────────────────────────────────────────────────────

class _AiAppBar extends StatelessWidget {
  final VoidCallback? onClear;
  final VoidCallback onVoice;

  const _AiAppBar({this.onClear, required this.onVoice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        16,
        12,
      ),
      decoration: const BoxDecoration(
        gradient: AppGradients.heroNavy,
      ),
      child: Row(
        children: [
          // Logo + title
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppGradients.heroBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.smart_toy_rounded,
                color: Colors.white, size: 18),
          )
              .animate(
              onPlay: (c) => c.repeat(reverse: true))
              .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.06, 1.06),
            duration: 2500.ms,
            curve: Curves.easeInOut,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'UniLink AI',
                      style: AppTypography.h3.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                        AppColors.success.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppColors.success
                                .withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Online',
                            style:
                            AppTypography.caption.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  'Your personal career guide',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // Voice button
          GestureDetector(
            onTap: onVoice,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.mic_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 8),

          // Clear history
          if (onClear != null)
            GestureDetector(
              onTap: onClear,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.refresh_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Welcome view ─────────────────────────────────────────────────────────

class _WelcomeView extends StatelessWidget {
  final void Function(String prompt) onPromptTap;

  const _WelcomeView({required this.onPromptTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: AiQuickPrompts(onPromptTap: onPromptTap),
    );
  }
}

// ─── Messages view ────────────────────────────────────────────────────────

class _MessagesView extends StatelessWidget {
  final List<dynamic> messages;
  final ScrollController scrollController;
  final bool isTyping;
  final void Function(String route, String id) onActionTap;
  final void Function(String prompt) onSuggestionTap;

  const _MessagesView({
    required this.messages,
    required this.scrollController,
    required this.isTyping,
    required this.onActionTap,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        // Messages are reversed — index 0 = newest
        final message = messages[messages.length - 1 - index];
        return AiMessageBubble(
          message: message,
          onActionTap: onActionTap,
          onSuggestionTap: onSuggestionTap,
        ).animate().fadeIn(duration: 300.ms).slideY(
          begin: 0.05,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOut,
        );
      },
    );
  }
}

// ─── AI input bar ─────────────────────────────────────────────────────────

class _AiInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasText;
  final bool isTyping;
  final VoidCallback onSend;
  final VoidCallback onVoice;

  const _AiInputBar({
    required this.controller,
    required this.focusNode,
    required this.hasText,
    required this.isTyping,
    required this.onSend,
    required this.onVoice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        10,
        12,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Voice input button
          GestureDetector(
            onTap: onVoice,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppGradients.heroBlue,
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color:
                    AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.mic_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 8),

          // Text input
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: AppTypography.bodyM
                    .copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: isTyping
                      ? 'AI is responding...'
                      : 'Ask anything about your future...',
                  hintStyle: AppTypography.bodyS.copyWith(
                    color: isTyping
                        ? AppColors.primaryBlue
                        : AppColors.textMuted,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send button
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: hasText && !isTyping
                ? GestureDetector(
              key: const ValueKey('send'),
              onTap: onSend,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppGradients.heroBlue,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue
                          .withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            )
                : Container(
              key: const ValueKey('idle'),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                isTyping
                    ? Icons.hourglass_bottom_rounded
                    : Icons.arrow_upward_rounded,
                size: 20,
                color: isTyping
                    ? AppColors.primaryBlue
                    : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}