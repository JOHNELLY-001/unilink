import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/navigation/animated_bottom_nav.dart';
import '../../shared/widgets/navigation/app_drawer.dart';
import '../../providers/message_provider.dart';
import '../../providers/auth_provider.dart';

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

// ─── Tab routes ───────────────────────────────────────────────────────────

const _tabRoutes = [
  AppRoutes.dashboard,
  AppRoutes.careers,
  AppRoutes.mentors,
  AppRoutes.community,
  AppRoutes.aiAssistant,
];

// ─── App Shell ────────────────────────────────────────────────────────────

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _locationToIndex(String location) {
    for (int i = 0; i < _tabRoutes.length; i++) {
      if (location.startsWith(_tabRoutes[i])) return i;
    }
    return 0;
  }

  bool _shouldShowFab(int currentIndex) {
    // Don't show FAB on AI tab (already there)
    return currentIndex != 4;
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
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
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
      floatingActionButton: _shouldShowFab(currentIndex)
          ? _FloatingAiButton(
        onTap: () => context.go(AppRoutes.aiAssistant),
      )
          .animate()
          .scale(
        begin: const Offset(0, 0),
        duration: 400.ms,
        delay: 100.ms,
        curve: Curves.elasticOut,
      )
          : null,
      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat,
    );
  }
}

// ─── Floating AI button ───────────────────────────────────────────────────

class _FloatingAiButton extends StatefulWidget {
  final VoidCallback onTap;

  const _FloatingAiButton({required this.onTap});

  @override
  State<_FloatingAiButton> createState() =>
      _FloatingAiButtonState();
}

class _FloatingAiButtonState extends State<_FloatingAiButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6)
        .animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) => Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.primaryBlueMid,
                AppColors.accentTeal,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue
                    .withOpacity(_glowAnimation.value),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.smart_toy_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}