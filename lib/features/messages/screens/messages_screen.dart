import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_spacing.dart';
import '../../../providers/message_provider.dart';
import '../../../models/message_model.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/loaders/shimmer_loader.dart';
import '../../../shared/widgets/empty_states/empty_state_widget.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/inputs/search_bar_widget.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() =>
      _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            backgroundColor: AppColors.white,
            floating: true,
            snap: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Messages', style: AppTypography.h2),
                conversationsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (convs) {
                    final unread = convs
                        .fold(0, (s, c) => s + c.unreadCount);
                    return Text(
                      unread > 0
                          ? '$unread unread message${unread != 1 ? 's' : ''}'
                          : 'Your mentor conversations',
                      style: AppTypography.caption,
                    );
                  },
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SearchBarWidget(
                  hint: 'Search conversations...',
                  controller: _searchController,
                  onChanged: (q) =>
                      setState(() => _searchQuery = q),
                ),
              ),
            ),
          ),
        ],
        body: conversationsAsync.when(
          loading: () => ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            itemCount: 4,
            separatorBuilder: (_, __) =>
            const SizedBox(height: 2),
            itemBuilder: (_, __) => const MentorCardSkeleton(),
          ),
          error: (err, _) => EmptyStateWidget(
            title: 'Could not load messages',
            message: err.toString(),
            emoji: '😕',
            actionLabel: 'Retry',
            onAction: () => ref.invalidate(conversationsProvider),
          ),
          data: (conversations) {
            final filtered = _searchQuery.isEmpty
                ? conversations
                : conversations
                .where((c) => c.participantName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
                .toList();

            if (filtered.isEmpty) {
              return EmptyStateWidget(
                title: _searchQuery.isNotEmpty
                    ? 'No results found'
                    : 'No conversations yet',
                message: _searchQuery.isNotEmpty
                    ? 'Try a different name.'
                    : 'Book a mentor session to start a conversation.',
                emoji: _searchQuery.isNotEmpty ? '🔍' : '💬',
              );
            }

            return ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                indent: 76,
                color: AppColors.borderLight,
              ),
              itemBuilder: (context, index) =>
                  _ConversationTile(
                    conversation: filtered[index],
                    onTap: () => context.push(
                        AppRoutes.chatPath(filtered[index].id)),
                  )
                      .animate()
                      .fadeIn(
                    delay: Duration(
                        milliseconds: 40 * index),
                    duration: 300.ms,
                  ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Conversation tile ────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  String _timeLabel(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: hasUnread
            ? AppColors.primaryBlue.withOpacity(0.025)
            : AppColors.white,
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Avatar with online dot
            Stack(
              children: [
                AvatarWidget(
                  imageUrl: conversation.participantAvatarUrl,
                  name: conversation.participantName,
                  size: 52,
                ),
                if (conversation.isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.participantName,
                          style: AppTypography.labelL.copyWith(
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _timeLabel(conversation.updatedAt),
                        style: AppTypography.caption.copyWith(
                          color: hasUnread
                              ? AppColors.primaryBlue
                              : AppColors.textMuted,
                          fontWeight: hasUnread
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      // Sent indicator
                      if (conversation.lastMessage
                          ?.isSentByMe ==
                          true) ...[
                        const Icon(
                          Icons.done_all_rounded,
                          size: 14,
                          color: AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          conversation.lastMessage?.content ??
                              'Start a conversation',
                          style: AppTypography.bodyS.copyWith(
                            color: hasUnread
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${conversation.unreadCount}',
                              style: AppTypography.caption
                                  .copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Role badge
                  Text(
                    conversation.participantRole == 'mentor'
                        ? '🎓 Mentor'
                        : '👤 Student',
                    style: AppTypography.caption.copyWith(
                      color: conversation.participantRole ==
                          'mentor'
                          ? AppColors.primaryBlue
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}