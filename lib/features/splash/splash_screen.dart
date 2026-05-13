import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_gradients.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../core/constants/app_constants.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _navigate();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    // Wait for minimum splash display time
    await Future.delayed(
        const Duration(milliseconds: AppConstants.splashDuration));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete =
        prefs.getBool(AppConstants.keyOnboardingComplete) ?? false;

    final authState = ref.read(authProvider);

    if (!onboardingComplete) {
      if (mounted) context.go(AppRoutes.onboarding);
      return;
    }

    if (authState.isAuthenticated) {
      if (mounted) context.go(AppRoutes.dashboard);
    } else {
      if (mounted) context.go(AppRoutes.explorePublic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.heroNavy),
        child: Stack(
          children: [
            // ─── Background decorative circles ───────────────────────
            Positioned(
              top: -size.width * 0.3,
              right: -size.width * 0.2,
              child: _GlowCircle(
                size: size.width * 0.8,
                color: AppColors.primaryBlue.withOpacity(0.15),
              )
                  .animate(controller: _pulseController)
                  .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
              ),
            ),
            Positioned(
              bottom: -size.width * 0.2,
              left: -size.width * 0.1,
              child: _GlowCircle(
                size: size.width * 0.6,
                color: AppColors.accentTeal.withOpacity(0.12),
              )
                  .animate(controller: _pulseController)
                  .scale(
                begin: const Offset(1.1, 1.1),
                end: const Offset(0.9, 0.9),
              ),
            ),
            Positioned(
              top: size.height * 0.35,
              left: -size.width * 0.15,
              child: _GlowCircle(
                size: size.width * 0.4,
                color: AppColors.accentCyan.withOpacity(0.08),
              ),
            ),

            // ─── Main content ─────────────────────────────────────────
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo mark
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) => Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    ),
                    child: _LogoMark(),
                  )
                      .animate()
                      .scale(
                    begin: const Offset(0.3, 0.3),
                    duration: 700.ms,
                    curve: Curves.elasticOut,
                  )
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 24),

                  // App name
                  Text(
                    AppConstants.appName,
                    style: AppTypography.displayL.copyWith(
                      color: AppColors.white,
                      letterSpacing: -1.0,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 500.ms)
                      .slideY(
                    begin: 0.3,
                    end: 0,
                    delay: 300.ms,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),

                  const SizedBox(height: 10),

                  // Tagline
                  Text(
                    AppConstants.appTagline,
                    style: AppTypography.bodyM.copyWith(
                      color: AppColors.white.withOpacity(0.65),
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 500.ms),

                  const SizedBox(height: 60),

                  // Loading indicator
                  _LoadingDots()
                      .animate()
                      .fadeIn(delay: 700.ms, duration: 400.ms),
                ],
              ),
            ),

            // ─── Made in Tanzania badge ───────────────────────────────
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Text(
                'Made with ❤️ in Tanzania 🇹🇿',
                style: AppTypography.caption.copyWith(
                  color: AppColors.white.withOpacity(0.4),
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 900.ms, duration: 500.ms),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Logo Mark ────────────────────────────────────────────────────────────

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.accentTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.5),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: AppColors.accentTeal.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Link chain icon — represents UniLink connection
          const Icon(
            Icons.link_rounded,
            color: Colors.white,
            size: 44,
          ),
          // Subtle shine overlay
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Glow Circle ──────────────────────────────────────────────────────────

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

// ─── Loading Dots ─────────────────────────────────────────────────────────

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
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
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final opacity = value < 0.5
                ? value * 2
                : (1.0 - value) * 2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Opacity(
                opacity: (0.3 + opacity * 0.7).clamp(0.3, 1.0),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}