import 'package:flutter/material.dart';
import '../../../models/resource_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_shadows.dart';

class ResourceCard extends StatelessWidget {
  final ResourceModel resource;
  final VoidCallback? onTap;
  final VoidCallback? onSave;

  const ResourceCard({
    super.key,
    required this.resource,
    this.onTap,
    this.onSave,
  });

  Color get _typeColor {
    switch (resource.type) {
      case ResourceType.video:
        return AppColors.error;
      case ResourceType.pdf:
        return AppColors.primaryBlue;
      case ResourceType.guide:
        return AppColors.accentTeal;
      case ResourceType.roadmap:
        return AppColors.premiumPurple;
      case ResourceType.article:
        return AppColors.warning;
      case ResourceType.template:
        return AppColors.success;
    }
  }

  IconData get _typeIcon {
    switch (resource.type) {
      case ResourceType.video:
        return Icons.play_circle_rounded;
      case ResourceType.pdf:
        return Icons.picture_as_pdf_rounded;
      case ResourceType.guide:
        return Icons.menu_book_rounded;
      case ResourceType.roadmap:
        return Icons.map_rounded;
      case ResourceType.article:
        return Icons.article_rounded;
      case ResourceType.template:
        return Icons.description_rounded;
    }
  }

  String get _typeLabel {
    switch (resource.type) {
      case ResourceType.video:
        return 'Video';
      case ResourceType.pdf:
        return 'PDF';
      case ResourceType.guide:
        return 'Guide';
      case ResourceType.roadmap:
        return 'Roadmap';
      case ResourceType.article:
        return 'Article';
      case ResourceType.template:
        return 'Template';
    }
  }

  String? get _durationLabel {
    if (resource.durationMinutes != null) {
      final m = resource.durationMinutes!;
      if (m >= 60) {
        return '${(m / 60).toStringAsFixed(1)}h';
      }
      return '${m}min';
    }
    if (resource.pageCount != null) {
      return '${resource.pageCount} pages';
    }
    return null;
  }

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Type icon ───────────────────────────────────
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_typeIcon, color: _typeColor, size: 26),
            ),
            const SizedBox(width: 12),

            // ─── Content ─────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type + AI recommended badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: _typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _typeLabel,
                          style: AppTypography.caption.copyWith(
                            color: _typeColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (resource.isAiRecommended) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.premiumPurple
                                .withOpacity(0.1),
                            borderRadius:
                            BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.auto_awesome_rounded,
                                size: 10,
                                color: AppColors.premiumPurple,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'AI Pick',
                                style: AppTypography.caption
                                    .copyWith(
                                  color:
                                  AppColors.premiumPurple,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (!resource.isFree) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.premiumGoldLight,
                            borderRadius:
                            BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Pro',
                            style: AppTypography.caption
                                .copyWith(
                              color: AppColors.premiumGold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    resource.title,
                    style: AppTypography.h4,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  // Author
                  Text(
                    'by ${resource.author}',
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Meta row
                  Row(
                    children: [
                      // Rating
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 12,
                              color: AppColors.premiumGold),
                          const SizedBox(width: 3),
                          Text(
                            resource.rating.toStringAsFixed(1),
                            style: AppTypography.caption
                                .copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      // Views
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.visibility_rounded,
                              size: 12,
                              color: AppColors.textMuted),
                          const SizedBox(width: 3),
                          Text(
                            _formatViews(resource.viewCount),
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                      if (_durationLabel != null) ...[
                        const SizedBox(width: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule_rounded,
                                size: 12,
                                color: AppColors.textMuted),
                            const SizedBox(width: 3),
                            Text(
                              _durationLabel!,
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ],
                      const Spacer(),
                      // Save button
                      GestureDetector(
                        onTap: onSave,
                        child: AnimatedContainer(
                          duration:
                          const Duration(milliseconds: 200),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: resource.isSaved
                                ? AppColors.primaryBlue
                                .withOpacity(0.1)
                                : AppColors.surfaceMuted,
                            borderRadius:
                            BorderRadius.circular(8),
                          ),
                          child: Icon(
                            resource.isSaved
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_outline_rounded,
                            size: 16,
                            color: resource.isSaved
                                ? AppColors.primaryBlue
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatViews(int views) {
    if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}k views';
    }
    return '$views views';
  }
}