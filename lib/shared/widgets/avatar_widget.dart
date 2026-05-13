import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final bool showOnlineBadge;
  final bool isOnline;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 44,
    this.showOnlineBadge = false,
    this.isOnline = false,
    this.onTap,
    this.backgroundColor,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length.clamp(0, 2)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor ?? AppColors.primaryBlue.withOpacity(0.12),
              border: Border.all(
                  color: AppColors.white, width: size > 40 ? 2.5 : 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryNavy.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => _InitialsAvatar(
                    initials: _initials,
                    size: size,
                    backgroundColor: backgroundColor),
                errorWidget: (_, __, ___) => _InitialsAvatar(
                    initials: _initials,
                    size: size,
                    backgroundColor: backgroundColor),
              )
                  : _InitialsAvatar(
                  initials: _initials,
                  size: size,
                  backgroundColor: backgroundColor),
            ),
          ),
          if (showOnlineBadge)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: size * 0.25,
                height: size * 0.25,
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.success : AppColors.textMuted,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color? backgroundColor;

  const _InitialsAvatar({
    required this.initials,
    required this.size,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: backgroundColor ?? AppColors.primaryBlue.withOpacity(0.12),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTypography.labelL.copyWith(
          color: AppColors.primaryBlue,
          fontSize: size * 0.32,
        ),
      ),
    );
  }
}