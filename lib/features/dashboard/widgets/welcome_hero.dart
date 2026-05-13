import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_gradients.dart';
import '../../../models/user_model.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/badges/premium_badge.dart';

class WelcomeHero extends StatelessWidget {
  final UserModel? user;
  final VoidCallback onDrawerTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onAiTap;

  const WelcomeHero({
    super.key,
    required this.user,
    required this.onDrawerTap,
    required this.onNotificationTap,
    required this.onAiTap,
  });

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        28,
      ),
      decoration: const BoxDecoration(gradient: AppGradients.heroNavy),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Top bar ────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onDrawerTap,
                child: AvatarWidget(
                  imageUrl: user?.avatarUrl,
                  name: user?.fullName ?? 'User',
                  size: 42,
                ),
              ).animate().fadeIn(duration: 400.ms),

              Row(
                children: [
                  if (user?.isPro == true)
                    const Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: PremiumBadge(),
                    ),
                  // Notification bell
                  GestureDetector(
                    onTap: onNotificationTap,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.white,
                            size: 20,
                          ),
                          // Unread dot
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                ],
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ─── Greeting ────────────────────────────────────────────
          Text(
            '$_greeting,',
            style: AppTypography.bodyL.copyWith(
              color: AppColors.white.withOpacity(0.7),
            ),
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 2),

          Text(
            '${user?.firstName ?? 'there'} 👋',
            style: AppTypography.displayM.copyWith(
              color: AppColors.white,
              height: 1.15,
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 500.ms)
              .slideY(
            begin: 0.15,
            end: 0,
            delay: 200.ms,
            duration: 500.ms,
            curve: Curves.easeOut,
          ),

          const SizedBox(height: 6),

          // Education level pill
          if (user?.educationLevel != null)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentTeal.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.accentTeal.withOpacity(0.4)),
              ),
              child: Text(
                '${user!.educationLevel!.displayName} • ${user!.schoolOrUniversity ?? 'UniLink'}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.accentTealLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 20),

          // ─── Profile completion bar ───────────────────────────────
          if (user != null && !user!.isProfileComplete)
            _ProfileCompletionWidget(user: user!)
                .animate()
                .fadeIn(delay: 400.ms),

          // ─── AI quick access ──────────────────────────────────────
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onAiTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.white.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.smart_toy_rounded,
                      color: AppColors.accentTealLight, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ask AI: "What should I study for software engineering?"',
                      style: AppTypography.bodyS.copyWith(
                        color: AppColors.white.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 12, color: AppColors.white),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}

class _ProfileCompletionWidget extends StatelessWidget {
  final UserModel user;

  const _ProfileCompletionWidget({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profile ${user.profileCompletionPercent}% complete',
              style: AppTypography.caption.copyWith(
                color: AppColors.white.withOpacity(0.75),
              ),
            ),
            Text(
              'Complete now →',
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
            value: user.profileCompletionPercent / 100,
            backgroundColor: Colors.white.withOpacity(0.15),
            valueColor: const AlwaysStoppedAnimation(
                AppColors.accentTealLight),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}