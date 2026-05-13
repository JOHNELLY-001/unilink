import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../models/mentor_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_shadows.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/badges/tag_chip.dart';

// ─── Full list card (mentors screen) ─────────────────────────────────────

class MentorListCard extends StatefulWidget {
  final MentorModel mentor;
  final VoidCallback onTap;
  final VoidCallback? onBook;

  const MentorListCard({
    super.key,
    required this.mentor,
    required this.onTap,
    this.onBook,
  });

  @override
  State<MentorListCard> createState() => _MentorListCardState();
}

class _MentorListCardState extends State<MentorListCard> {
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
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: AppShadows.cardShadow,
          ),
          child: Column(
            children: [
              // ─── Top section ───────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar with online badge
                    Stack(
                      children: [
                        AvatarWidget(
                          imageUrl: widget.mentor.avatarUrl,
                          name: widget.mentor.fullName,
                          size: 60,
                        ),
                        if (widget.mentor.isAvailable)
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.white,
                                    width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          // Name + verified badge
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.mentor.fullName,
                                  style: AppTypography.h3,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.mentor.isApproved)
                                const Padding(
                                  padding:
                                  EdgeInsets.only(left: 6),
                                  child: Icon(
                                    Icons.verified_rounded,
                                    size: 16,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.mentor.title} @ ${widget.mentor.company}',
                            style: AppTypography.bodyS,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 12,
                                  color: AppColors.textMuted),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  widget.mentor.location,
                                  style: AppTypography.caption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Rating + sessions + price
                          Row(
                            children: [
                              _RatingBadge(
                                  rating: widget.mentor.rating),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.mentor.totalSessions} sessions',
                                style: AppTypography.caption,
                              ),
                              const Spacer(),
                              _PriceBadge(
                                  mentor: widget.mentor),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Expertise chips ───────────────────────────
              Padding(
                padding:
                const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SizedBox(
                  height: 28,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.mentor.expertise.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(width: 6),
                    itemBuilder: (context, i) => TagChip(
                      label: widget.mentor.expertise[i],
                      small: true,
                    ),
                  ),
                ),
              ),

              // ─── Bottom action row ─────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(
                    16, 10, 16, 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Row(
                  children: [
                    // Availability
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: widget.mentor.isAvailable
                                ? AppColors.success
                                : AppColors.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.mentor.isAvailable
                              ? 'Available now'
                              : 'Unavailable',
                          style: AppTypography.caption.copyWith(
                            color: widget.mentor.isAvailable
                                ? AppColors.success
                                : AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Book button
                    if (widget.mentor.isAvailable &&
                        widget.onBook != null)
                      GestureDetector(
                        onTap: widget.onBook,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                          child: Text(
                            widget.mentor.offersFreeIntro
                                ? 'Book Free Session'
                                : 'Book Session',
                            style: AppTypography.labelS.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Compact grid card ────────────────────────────────────────────────────

class MentorGridCard extends StatelessWidget {
  final MentorModel mentor;
  final VoidCallback onTap;

  const MentorGridCard({
    super.key,
    required this.mentor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                AvatarWidget(
                  imageUrl: mentor.avatarUrl,
                  name: mentor.fullName,
                  size: 56,
                ),
                if (mentor.isAvailable)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
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
            const SizedBox(height: 10),
            Text(
              mentor.fullName,
              style: AppTypography.labelL,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              mentor.title,
              style: AppTypography.caption,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RatingBadge(rating: mentor.rating, small: true),
                const SizedBox(width: 6),
                _PriceBadge(mentor: mentor, small: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Supporting sub-widgets ───────────────────────────────────────────────

class _RatingBadge extends StatelessWidget {
  final double rating;
  final bool small;

  const _RatingBadge({required this.rating, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded,
            size: small ? 11 : 13,
            color: AppColors.premiumGold),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: (small ? AppTypography.caption : AppTypography.labelS)
              .copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PriceBadge extends StatelessWidget {
  final MentorModel mentor;
  final bool small;

  const _PriceBadge({required this.mentor, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: mentor.isFree
            ? AppColors.successLight
            : AppColors.infoLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        mentor.displayPrice,
        style: (small ? AppTypography.caption : AppTypography.labelS)
            .copyWith(
          color: mentor.isFree
              ? AppColors.success
              : AppColors.primaryBlue,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Review card ──────────────────────────────────────────────────────────

class MentorReviewCard extends StatelessWidget {
  final MentorReviewModel review;

  const MentorReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarWidget(
                imageUrl: review.reviewerAvatarUrl,
                name: review.reviewerName,
                size: 36,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.reviewerName,
                        style: AppTypography.labelL),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < review.rating.round()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 13,
                          color: AppColors.premiumGold,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: AppTypography.caption,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(review.comment, style: AppTypography.bodyS),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}