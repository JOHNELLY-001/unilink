import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_gradients.dart';
import '../../../theme/app_spacing.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_routes.dart';
import '../avatar_widget.dart';
import '../badges/premium_badge.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Drawer(
      backgroundColor: AppColors.white,
      width: MediaQuery.of(context).size.width * 0.82,
      child: Column(
        children: [
          // ─── Header ─────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 20, 20, 24),
            decoration: const BoxDecoration(gradient: AppGradients.heroNavy),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AvatarWidget(
                      imageUrl: user?.avatarUrl,
                      name: user?.fullName ?? 'Guest',
                      size: 52,
                    ),
                    if (user?.isPro == true)
                      const PremiumBadge(label: 'PRO')
                    else
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          context.push(AppRoutes.upgrade);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: AppGradients.premium,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Upgrade',
                              style: AppTypography.labelS.copyWith(
                                  color: AppColors.white)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  user?.fullName ?? 'Guest User',
                  style: AppTypography.h3
                      .copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.educationLevel?.displayName ??
                      user?.role.displayName ??
                      'Explore UniLink',
                  style: AppTypography.bodyS.copyWith(
                    color: AppColors.white.withOpacity(0.7),
                  ),
                ),
                if (user != null &&
                    !user.isProfileComplete) ...[
                  const SizedBox(height: 12),
                  _ProfileCompletionBar(
                      percent: user.profileCompletionPercent),
                ],
              ],
            ),
          ),

          // ─── Menu Items ─────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerSection(
                  title: 'Explore',
                  items: [
                    _DrawerItem(
                      icon: Icons.explore_outlined,
                      activeIcon: Icons.explore,
                      label: 'Opportunities',
                      route: AppRoutes.opportunities,
                      onTap: () => _navigate(context, AppRoutes.opportunities),
                    ),
                    _DrawerItem(
                      icon: Icons.menu_book_outlined,
                      activeIcon: Icons.menu_book,
                      label: 'Resources',
                      route: AppRoutes.resources,
                      onTap: () => _navigate(context, AppRoutes.resources),
                    ),
                  ],
                ),
                _DrawerSection(
                  title: 'Personal',
                  items: [
                    _DrawerItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      activeIcon: Icons.chat_bubble_rounded,
                      label: 'Messages',
                      route: AppRoutes.messages,
                      onTap: () => _navigate(context, AppRoutes.messages),
                      badge: '2',
                    ),
                    _DrawerItem(
                      icon: Icons.trending_up_outlined,
                      activeIcon: Icons.trending_up,
                      label: 'My Progress',
                      route: AppRoutes.progress,
                      onTap: () => _navigate(context, AppRoutes.progress),
                    ),
                    _DrawerItem(
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: 'Profile',
                      route: AppRoutes.profile,
                      onTap: () => _navigate(context, AppRoutes.profile),
                    ),
                  ],
                ),
                _DrawerSection(
                  title: 'Settings',
                  items: [
                    _DrawerItem(
                      icon: Icons.settings_outlined,
                      activeIcon: Icons.settings,
                      label: 'Settings',
                      route: AppRoutes.settings,
                      onTap: () => _navigate(context, AppRoutes.settings),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ─── Footer ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              children: [
                const Divider(height: 1),
                const SizedBox(height: 16),
                if (user != null && !user.isGuest)
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      await ref.read(authProvider.notifier).signOut();
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.logout_rounded,
                            size: 20,
                            color: AppColors.error),
                        const SizedBox(width: 12),
                        Text(
                          'Sign Out',
                          style: AppTypography.labelL.copyWith(
                              color: AppColors.error),
                        ),
                      ],
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.signIn);
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.login_rounded,
                            size: 20,
                            color: AppColors.primaryBlue),
                        const SizedBox(width: 12),
                        Text(
                          'Sign In / Register',
                          style: AppTypography.labelL.copyWith(
                              color: AppColors.primaryBlue),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  'UniLink v1.0.0 • Made in Tanzania 🇹🇿',
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context);
    context.push(route);
  }
}

// ─── Supporting widgets ───────────────────────────────────────────────────

class _DrawerSection extends StatelessWidget {
  final String title;
  final List<_DrawerItem> items;

  const _DrawerSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text(
            title.toUpperCase(),
            style: AppTypography.labelS,
          ),
        ),
        ...items,
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final VoidCallback onTap;
  final String? badge;

  const _DrawerItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isActive =
    GoRouterState.of(context).matchedLocation.startsWith(route);

    return ListTile(
      onTap: onTap,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: isActive
          ? AppColors.primaryBlue.withOpacity(0.08)
          : null,
      leading: Icon(
        isActive ? activeIcon : icon,
        color: isActive ? AppColors.primaryBlue : AppColors.textSecondary,
        size: 22,
      ),
      title: Text(
        label,
        style: AppTypography.labelL.copyWith(
          color: isActive
              ? AppColors.primaryBlue
              : AppColors.textSecondary,
        ),
      ),
      trailing: badge != null
          ? Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          badge!,
          style: AppTypography.caption.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700),
        ),
      )
          : null,
    );
  }
}

class _ProfileCompletionBar extends StatelessWidget {
  final int percent;

  const _ProfileCompletionBar({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profile ${percent}% complete',
              style: AppTypography.caption
                  .copyWith(color: AppColors.white.withOpacity(0.8)),
            ),
            Text(
              'Complete →',
              style: AppTypography.caption.copyWith(
                color: AppColors.accentTealLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent / 100,
            backgroundColor: AppColors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation(
                AppColors.accentTealLight),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}