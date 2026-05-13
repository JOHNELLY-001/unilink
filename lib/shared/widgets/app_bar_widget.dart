import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Reusable custom AppBar used across all screens.
/// Matches the design system and keeps a consistent look.
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final double elevation;

  const AppBarWidget({
    super.key,
    required this.title,
    this.showBack = true,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.centerTitle = false,
    this.bottom,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: AppTypography.h3),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.white,
      elevation: elevation,
      scrolledUnderElevation: 0.5,
      leading: leading ??
          (showBack
              ? IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            onPressed: () => Navigator.maybePop(context),
            color: AppColors.textPrimary,
          )
              : null),
      automaticallyImplyLeading: showBack,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}