import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../models/post_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../shared/widgets/avatar_widget.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback? onReact;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final void Function(String optionId)? onVote;

  const PostCard({
    super.key,
    required this.post,
    this.onReact,
    this.onComment,
    this.onShare,
    this.onVote,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isExpanded = false;
  static const _maxCollapsedLength = 220;

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.post.isPinned
              ? AppColors.primaryBlue.withOpacity(0.3)
              : AppColors.borderLight,
          width: widget.post.isPinned ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Pinned indicator ────────────────────────────────
          if (widget.post.isPinned)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.06),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.push_pin_rounded,
                      size: 13, color: AppColors.primaryBlue),
                  const SizedBox(width: 6),
                  Text(
                    'Pinned post',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Author row ────────────────────────────────
                Row(
                  children: [
                    AvatarWidget(
                      imageUrl: widget.post.authorAvatarUrl,
                      name: widget.post.authorName,
                      size: 40,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.post.authorName,
                                style: AppTypography.labelL,
                              ),
                              if (widget.post.authorRole ==
                                  'mentor') ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 14,
                                  color: AppColors.primaryBlue,
                                ),
                              ],
                            ],
                          ),
                          Text(
                            widget.post.authorTitle ??
                                _roleLabel(
                                    widget.post.authorRole),
                            style: AppTypography.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _timeAgo(widget.post.createdAt),
                      style: AppTypography.caption,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ─── Content ───────────────────────────────────
                _PostContent(
                  content: widget.post.content,
                  isExpanded: _isExpanded,
                  maxLength: _maxCollapsedLength,
                  onToggle: () =>
                      setState(() => _isExpanded = !_isExpanded),
                ),

                // ─── Poll ──────────────────────────────────────
                if (widget.post.poll != null) ...[
                  const SizedBox(height: 12),
                  _PollWidget(
                    poll: widget.post.poll!,
                    onVote: widget.onVote,
                  ),
                ],

                // ─── Tags ──────────────────────────────────────
                if (widget.post.tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: widget.post.tags.map((tag) {
                      return Text(
                        '#$tag',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

          // ─── Reaction bar ──────────────────────────────────
          _ReactionBar(
            post: widget.post,
            onReact: widget.onReact,
            onComment: widget.onComment,
            onShare: widget.onShare,
          ),
        ],
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'mentor':
        return 'Mentor / Professional';
      case 'student':
        return 'Student';
      default:
        return role;
    }
  }
}

// ─── Post content with expand/collapse ───────────────────────────────────

class _PostContent extends StatelessWidget {
  final String content;
  final bool isExpanded;
  final int maxLength;
  final VoidCallback onToggle;

  const _PostContent({
    required this.content,
    required this.isExpanded,
    required this.maxLength,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isLong = content.length > maxLength;
    final displayText =
    isLong && !isExpanded
        ? '${content.substring(0, maxLength)}...'
        : content;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayText,
          style: AppTypography.bodyM.copyWith(
            color: AppColors.textPrimary,
            height: 1.55,
          ),
        ),
        if (isLong) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onToggle,
            child: Text(
              isExpanded ? 'Show less' : 'Read more',
              style: AppTypography.labelS.copyWith(
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Poll widget ──────────────────────────────────────────────────────────

class _PollWidget extends StatelessWidget {
  final PollModel poll;
  final void Function(String optionId)? onVote;

  const _PollWidget({required this.poll, this.onVote});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(poll.question, style: AppTypography.labelL),
          const SizedBox(height: 10),
          ...poll.options.map((option) {
            final total = poll.totalVotes;
            final ratio =
            total > 0 ? option.voteCount / total : 0.0;
            final isVoted =
                poll.userVotedOptionId == option.id;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: poll.hasVoted
                    ? null
                    : () => onVote?.call(option.id),
                child: Stack(
                  children: [
                    // Background bar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isVoted
                              ? AppColors.primaryBlue
                              : AppColors.border,
                          width: isVoted ? 1.5 : 1,
                        ),
                      ),
                    ),
                    // Progress fill
                    if (poll.hasVoted)
                      Positioned.fill(
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: ratio,
                          child: AnimatedContainer(
                            duration:
                            const Duration(milliseconds: 600),
                            decoration: BoxDecoration(
                              color: isVoted
                                  ? AppColors.primaryBlue
                                  .withOpacity(0.12)
                                  : AppColors.surfaceMuted,
                              borderRadius:
                              BorderRadius.circular(9),
                            ),
                          ),
                        ),
                      ),
                    // Label + percent
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12),
                        child: Row(
                          children: [
                            if (isVoted)
                              const Padding(
                                padding:
                                EdgeInsets.only(right: 6),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  size: 14,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            Expanded(
                              child: Text(
                                option.text,
                                style: AppTypography.labelM
                                    .copyWith(
                                  color: isVoted
                                      ? AppColors.primaryBlue
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (poll.hasVoted)
                              Text(
                                '${(ratio * 100).round()}%',
                                style: AppTypography.labelS
                                    .copyWith(
                                  color: isVoted
                                      ? AppColors.primaryBlue
                                      : AppColors.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
          Text(
            '${poll.totalVotes} votes • ${_timeLeft(poll.endsAt)}',
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }

  String _timeLeft(DateTime endsAt) {
    final diff = endsAt.difference(DateTime.now());
    if (diff.isNegative) return 'Poll ended';
    if (diff.inDays > 0) return '${diff.inDays}d left';
    if (diff.inHours > 0) return '${diff.inHours}h left';
    return '${diff.inMinutes}m left';
  }
}

// ─── Reaction bar ─────────────────────────────────────────────────────────

class _ReactionBar extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onReact;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  const _ReactionBar({
    required this.post,
    this.onReact,
    this.onComment,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: Row(
        children: [
          // Reactions
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onReact?.call();
            },
            child: _ReactionButton(
              reactions: post.reactions,
              isLiked: post.isLikedByUser,
            ),
          ),
          const Spacer(),
          // Comment
          GestureDetector(
            onTap: onComment,
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline_rounded,
                    size: 16, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  '${post.commentCount}',
                  style: AppTypography.labelS
                      .copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Share
          GestureDetector(
            onTap: onShare,
            child: Row(
              children: [
                const Icon(Icons.share_outlined,
                    size: 16, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  '${post.shareCount}',
                  style: AppTypography.labelS
                      .copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final Map<String, int> reactions;
  final bool isLiked;

  const _ReactionButton({
    required this.reactions,
    required this.isLiked,
  });

  @override
  Widget build(BuildContext context) {
    final totalReactions =
    reactions.values.fold(0, (sum, c) => sum + c);
    final topEmojis =
    reactions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final displayEmojis =
    topEmojis.take(3).map((e) => e.key).toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isLiked
            ? AppColors.primaryBlue.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLiked
              ? AppColors.primaryBlue.withOpacity(0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji stack
          if (displayEmojis.isNotEmpty)
            Text(
              displayEmojis.join(''),
              style: const TextStyle(fontSize: 13),
            ),
          const SizedBox(width: 5),
          Text(
            totalReactions > 0
                ? '$totalReactions'
                : 'React',
            style: AppTypography.labelS.copyWith(
              color: isLiked
                  ? AppColors.primaryBlue
                  : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}