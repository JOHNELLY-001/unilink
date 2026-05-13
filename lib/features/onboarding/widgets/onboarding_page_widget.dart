import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class OnboardingPageData {
  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> gradientColors;
  final List<_FeatureItem> features;

  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradientColors,
    required this.features,
  });
}

class _FeatureItem {
  final IconData icon;
  final String label;
  const _FeatureItem(this.icon, this.label);
}

// ─── The 3 onboarding pages ───────────────────────────────────────────────

const onboardingPages = [
  OnboardingPageData(
    title: 'Discover Your\nPerfect Career',
    subtitle:
    'Explore 12+ career paths with real salary data, university pathways, and skill requirements tailored for Tanzania.',
    emoji: '🎯',
    gradientColors: [Color(0xFF0B1D3A), Color(0xFF1A3A6B)],
    features: [
      _FeatureItem(Icons.work_rounded, 'Explore careers'),
      _FeatureItem(Icons.school_rounded, 'University pathways'),
      _FeatureItem(Icons.payments_rounded, 'Real salary insights'),
    ],
  ),
  OnboardingPageData(
    title: 'Learn From\nReal Mentors',
    subtitle:
    'Connect with verified Tanzanian professionals. Book free 1-on-1 sessions, get career advice, and build your network.',
    emoji: '🤝',
    gradientColors: [Color(0xFF0D4F3C), Color(0xFF0D9488)],
    features: [
      _FeatureItem(Icons.verified_rounded, 'Verified professionals'),
      _FeatureItem(Icons.calendar_month_rounded, 'Book sessions'),
      _FeatureItem(Icons.chat_rounded, 'Direct messaging'),
    ],
  ),
  OnboardingPageData(
    title: 'AI That Guides\nYour Future',
    subtitle:
    'Your personal AI career coach available 24/7. Get scholarship recommendations, university advice, and custom roadmaps.',
    emoji: '🤖',
    gradientColors: [Color(0xFF1A56DB), Color(0xFF06B6D4)],
    features: [
      _FeatureItem(Icons.smart_toy_rounded, 'AI career coach'),
      _FeatureItem(Icons.school_rounded, 'Scholarship finder'),
      _FeatureItem(Icons.map_rounded, 'Custom roadmaps'),
    ],
  ),
];

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPageData data;
  final bool isActive;

  const OnboardingPageWidget({
    super.key,
    required this.data,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // ─── Decorative background elements ───────────────────────
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.15,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          // ─── Content ──────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.08),

                  // Emoji illustration
                  if (isActive)
                    Text(
                      data.emoji,
                      style: const TextStyle(fontSize: 72),
                    )
                        .animate()
                        .scale(
                      begin: const Offset(0.4, 0.4),
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    )
                        .fadeIn(duration: 300.ms)
                  else
                    Text(
                      data.emoji,
                      style: const TextStyle(fontSize: 72),
                    ),

                  SizedBox(height: size.height * 0.05),

                  // Title
                  if (isActive)
                    Text(
                      data.title,
                      style: AppTypography.displayL.copyWith(
                        color: AppColors.white,
                        height: 1.15,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 150.ms, duration: 500.ms)
                        .slideX(
                      begin: -0.15,
                      end: 0,
                      delay: 150.ms,
                      duration: 500.ms,
                      curve: Curves.easeOut,
                    )
                  else
                    Text(
                      data.title,
                      style: AppTypography.displayL.copyWith(
                        color: AppColors.white,
                        height: 1.15,
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Subtitle
                  if (isActive)
                    Text(
                      data.subtitle,
                      style: AppTypography.bodyL.copyWith(
                        color: AppColors.white.withOpacity(0.75),
                        height: 1.55,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 500.ms)
                  else
                    Text(
                      data.subtitle,
                      style: AppTypography.bodyL.copyWith(
                        color: AppColors.white.withOpacity(0.75),
                        height: 1.55,
                      ),
                    ),

                  const Spacer(),

                  // Feature pills
                  if (isActive)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: data.features.asMap().entries.map((entry) {
                        final index = entry.key;
                        final feature = entry.value;
                        return _FeaturePill(
                          icon: feature.icon,
                          label: feature.label,
                        )
                            .animate()
                            .fadeIn(
                          delay: Duration(milliseconds: 400 + index * 100),
                          duration: 400.ms,
                        )
                            .slideY(
                          begin: 0.3,
                          end: 0,
                          delay: Duration(
                              milliseconds: 400 + index * 100),
                          duration: 400.ms,
                          curve: Curves.easeOut,
                        );
                      }).toList(),
                    )
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: data.features
                          .map((f) => _FeaturePill(
                        icon: f.icon,
                        label: f.label,
                      ))
                          .toList(),
                    ),

                  SizedBox(height: size.height * 0.22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 7),
          Text(
            label,
            style: AppTypography.labelM.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}