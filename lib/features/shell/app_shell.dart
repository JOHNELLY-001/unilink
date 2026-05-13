import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/navigation/animated_bottom_nav.dart';
import '../../shared/widgets/navigation/app_drawer.dart';
import '../../providers/message_provider.dart';

// ─── Bottom nav tab definitions ───────────────────────────────────────────
const _navItems = [
  BottomNavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Home',
  ),
  BottomNavItem(
    icon: Icons.work_outline_rounded,
    activeIcon: Icons.work_rounded,
    label: 'Careers',
  ),
  BottomNavItem(
    icon: Icons.people_outline_rounded,
    activeIcon: Icons.people_rounded,
    label: 'Mentors',
  ),
  BottomNavItem(
    icon: Icons.forum_outlined,
    activeIcon: Icons.forum_rounded,
    label: 'Community',
  ),
  BottomNavItem(
    icon: Icons.smart_toy_outlined,
    activeIcon: Icons.smart_toy_rounded,
    label: 'AI',
  ),
];

// ─── Tab → route mapping ──────────────────────────────────────────────────
const _tabRoutes = [
  AppRoutes.dashboard,
  AppRoutes.careers,
  AppRoutes.mentors,
  AppRoutes.community,
  AppRoutes.aiAssistant,
];

// ─── Shell Provider ───────────────────────────────────────────────────────
final _currentTabIndexProvider = StateProvider<int>((ref) => 0);

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _locationToIndex(String location) {
    for (int i = 0; i < _tabRoutes.length; i++) {
      if (location.startsWith(_tabRoutes[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);
    final unreadAsync = ref.watch(totalUnreadCountProvider);
    final unreadCount = unreadAsync.valueOrNull ?? 0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: const AppDrawer(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: KeyedSubtree(
          key: ValueKey(location),
          child: child,
        ),
      ),
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: currentIndex,
        items: _navItems,
        onTap: (index) {
          if (index == currentIndex) return;
          context.go(_tabRoutes[index]);
        },
      ),

      // ─── Floating AI button (shown only when not on AI tab) ───────
      floatingActionButton: currentIndex != 4
          ? _FloatingAiButton(
        onTap: () => context.go(AppRoutes.aiAssistant),
      ).animate().scale(
        begin: const Offset(0, 0),
        duration: 400.ms,
        curve: Curves.elasticOut,
      )
          : null,
    );
  }
}

class _FloatingAiButton extends StatelessWidget {
  final VoidCallback onTap;

  const _FloatingAiButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryBlueMid, AppColors.accentTeal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.smart_toy_rounded,
          color: AppColors.white,
          size: 26,
        ),
      ),
    );
  }
}