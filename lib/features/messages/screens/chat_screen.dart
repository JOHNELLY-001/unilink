import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_spacing.dart';
import '../../../providers/message_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../../models/message_model.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/loaders/app_loader.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;
  bool _isRecording = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
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

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(currentUserProvider);
    HapticFeedback.lightImpact();

    setState(() => _isSending = true);
    _inputController.clear();

    await ref.read(messageRepositoryProvider).sendMessage(
      conversationId: widget.conversationId,
      senderId: user?.id ?? 'usr_001',
      content: text,
    );

    ref.invalidate(messagesProvider(widget.conversationId));
    setState(() => _isSending = false);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final messagesAsync =
    ref.watch(messagesProvider(widget.conversationId));

    // Find this conversation
    final conversation = conversationsAsync.valueOrNull
        ?.where((c) => c.id == widget.conversationId)
        .firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _ChatAppBar(conversation: conversation),
      body: Column(
        children: [
          // ─── Messages list ──────────────────────────────
          Expanded(
            child: messagesAsync.when(
              loading: () =>
              const AppLoader(message: 'Loading messages...'),
              error: (_, __) => const Center(
                child: Text('Could not load messages'),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return _EmptyChatView(
                    participantName:
                    conversation?.participantName ?? 'them',
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(
                      16, 16, 16, 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final prevMessage = index < messages.length - 1
                        ? messages[index + 1]
                        : null;
                    final showDateSeparator = prevMessage == null ||
                        !_isSameDay(
                            message.createdAt,
                            prevMessage.createdAt);

                    return Column(
                      children: [
                        if (showDateSeparator)
                          _DateSeparator(date: message.createdAt),
                        _MessageBubble(
                          message: message,
                          participantAvatarUrl:
                          conversation?.participantAvatarUrl,
                          participantName:
                          conversation?.participantName ?? '?',
                        )
                            .animate()
                            .fadeIn(duration: 250.ms)
                            .slideY(
                          begin: 0.05,
                          end: 0,
                          duration: 250.ms,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // ─── Input bar ──────────────────────────────────
          _ChatInputBar(
            controller: _inputController,
            isSending: _isSending,
            isRecording: _isRecording,
            onSend: _sendMessage,
            onVoiceToggle: () =>
                setState(() => _isRecording = !_isRecording),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }
}

// ─── Chat App Bar ─────────────────────────────────────────────────────────

class _ChatAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final dynamic conversation;

  const _ChatAppBar({required this.conversation});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_ios_rounded,
              size: 16, color: AppColors.textPrimary),
        ),
      ),
      title: conversation == null
          ? const SizedBox.shrink()
          : Row(
        children: [
          Stack(
            children: [
              AvatarWidget(
                imageUrl: conversation.participantAvatarUrl,
                name: conversation.participantName,
                size: 38,
              ),
              if (conversation.isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.white,
                          width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                conversation.participantName,
                style: AppTypography.h4,
              ),
              Text(
                conversation.isOnline
                    ? 'Online now'
                    : 'Last seen recently',
                style: AppTypography.caption.copyWith(
                  color: conversation.isOnline
                      ? AppColors.success
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.video_call_rounded,
              color: AppColors.primaryBlue, size: 24),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded,
              color: AppColors.textSecondary, size: 20),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// ─── Message bubble ───────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final String? participantAvatarUrl;
  final String participantName;

  const _MessageBubble({
    required this.message,
    required this.participantAvatarUrl,
    required this.participantName,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.isSentByMe;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Other person avatar
          if (!isMe) ...[
            AvatarWidget(
              imageUrl: participantAvatarUrl,
              name: participantName,
              size: 30,
            ),
            const SizedBox(width: 8),
          ],

          // Bubble
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth:
                    MediaQuery.of(context).size.width * 0.72,
                  ),
                  padding: _getBubblePadding(message.type),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.primaryBlue
                        : AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight:
                      Radius.circular(isMe ? 4 : 18),
                    ),
                    border: isMe
                        ? null
                        : Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryNavy
                            .withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _BubbleContent(
                      message: message, isMe: isMe),
                ),

                // Time
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: AppTypography.caption.copyWith(
                          fontSize: 10,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 3),
                        Icon(
                          message.isRead
                              ? Icons.done_all_rounded
                              : Icons.done_rounded,
                          size: 12,
                          color: message.isRead
                              ? AppColors.primaryBlue
                              : AppColors.textMuted,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }

  EdgeInsets _getBubblePadding(MessageType type) {
    if (type == MessageType.voice) {
      return const EdgeInsets.symmetric(
          horizontal: 14, vertical: 10);
    }
    return const EdgeInsets.symmetric(
        horizontal: 14, vertical: 10);
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}

// ─── Bubble content ───────────────────────────────────────────────────────

class _BubbleContent extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const _BubbleContent({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case MessageType.voice:
        return _VoiceMessageContent(isMe: isMe,
            duration: message.voiceDurationSeconds ?? 15);
      case MessageType.image:
        return _ImageMessageContent(url: message.mediaUrl ?? '');
      default:
        return Text(
          message.content,
          style: AppTypography.bodyM.copyWith(
            color: isMe ? AppColors.white : AppColors.textPrimary,
            height: 1.45,
          ),
        );
    }
  }
}

class _VoiceMessageContent extends StatefulWidget {
  final bool isMe;
  final int duration;

  const _VoiceMessageContent({
    required this.isMe,
    required this.duration,
  });

  @override
  State<_VoiceMessageContent> createState() =>
      _VoiceMessageContentState();
}

class _VoiceMessageContentState
    extends State<_VoiceMessageContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            setState(() => _isPlaying = !_isPlaying);
            if (_isPlaying) {
              _controller.forward(from: 0);
            } else {
              _controller.stop();
            }
          },
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: widget.isMe
                  ? Colors.white.withOpacity(0.2)
                  : AppColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              size: 18,
              color: widget.isMe
                  ? Colors.white
                  : AppColors.primaryBlue,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Waveform bars
        ...List.generate(20, (i) {
          final heights = [
            0.3, 0.6, 0.9, 0.5, 0.7, 0.4,
            0.8, 0.6, 0.9, 0.3, 0.7, 0.5,
            0.8, 0.4, 0.6, 0.9, 0.3, 0.5,
            0.7, 0.4,
          ];
          return Container(
            width: 3,
            height: 24 * heights[i],
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: widget.isMe
                  ? Colors.white.withOpacity(0.7)
                  : AppColors.primaryBlue.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
        const SizedBox(width: 8),
        Text(
          '${widget.duration}s',
          style: AppTypography.caption.copyWith(
            color: widget.isMe
                ? Colors.white.withOpacity(0.8)
                : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _ImageMessageContent extends StatelessWidget {
  final String url;

  const _ImageMessageContent({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 200,
        height: 150,
        color: AppColors.surfaceMuted,
        child: const Icon(Icons.image_rounded,
            color: AppColors.textMuted, size: 40),
      ),
    );
  }
}

// ─── Date separator ───────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  final DateTime date;

  const _DateSeparator({required this.date});

  String _label() {
    final now = DateTime.now();
    final today =
    DateTime(now.year, now.month, now.day);
    final msgDay =
    DateTime(date.year, date.month, date.day);
    final diff = today.difference(msgDay).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(
              child: Divider(color: AppColors.borderLight)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(_label(),
                  style: AppTypography.caption),
            ),
          ),
          const Expanded(
              child: Divider(color: AppColors.borderLight)),
        ],
      ),
    );
  }
}

// ─── Empty chat view ──────────────────────────────────────────────────────

class _EmptyChatView extends StatelessWidget {
  final String participantName;

  const _EmptyChatView({required this.participantName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 36,
              color: AppColors.primaryBlue,
            ),
          ).animate().scale(
            begin: const Offset(0.5, 0.5),
            duration: 500.ms,
            curve: Curves.elasticOut,
          ),
          const SizedBox(height: 16),
          Text(
            'Start the conversation',
            style: AppTypography.h3,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            'Say hello to $participantName and get started!',
            style: AppTypography.bodyS,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}

// ─── Chat input bar ───────────────────────────────────────────────────────

class _ChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final bool isSending;
  final bool isRecording;
  final VoidCallback onSend;
  final VoidCallback onVoiceToggle;

  const _ChatInputBar({
    required this.controller,
    required this.isSending,
    required this.isRecording,
    required this.onSend,
    required this.onVoiceToggle,
  });

  @override
  State<_ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<_ChatInputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      final hasText = widget.controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

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
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attachment
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.attach_file_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Text field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: widget.controller,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                style: AppTypography.bodyM
                    .copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: widget.isRecording
                      ? 'Recording voice message...'
                      : 'Type a message...',
                  hintStyle: AppTypography.bodyS.copyWith(
                    color: widget.isRecording
                        ? AppColors.error
                        : AppColors.textMuted,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send / voice button
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: _hasText
                ? GestureDetector(
              key: const ValueKey('send'),
              onTap: widget.onSend,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.isSending
                      ? AppColors.borderLight
                      : AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue
                          .withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: widget.isSending
                    ? const Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                        AppColors.white),
                  ),
                )
                    : const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            )
                : GestureDetector(
              key: const ValueKey('voice'),
              onTap: widget.onVoiceToggle,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.isRecording
                      ? AppColors.error
                      : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  widget.isRecording
                      ? Icons.stop_rounded
                      : Icons.mic_rounded,
                  size: 20,
                  color: widget.isRecording
                      ? AppColors.white
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}