import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_gradients.dart';
import '../../../theme/app_spacing.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/ghost_button.dart';

// ─── Role option data ─────────────────────────────────────────────────────

class _RoleOption {
  final String title;
  final String subtitle;
  final String description;
  final String emoji;
  final List<Color> gradient;
  final List<String> benefits;
  final String route;

  const _RoleOption({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.emoji,
    required this.gradient,
    required this.benefits,
    required this.route,
  });
}

const _roles = [
  _RoleOption(
    title: 'I\'m a Student',
    subtitle: 'Form 4 – University & Graduate',
    description:
    'Explore careers, find mentors, discover scholarships, and get AI-powered guidance for your education journey.',
    emoji: '🎓',
    gradient: [Color(0xFF1A56DB), Color(0xFF06B6D4)],
    benefits: [
      'Explore 12+ career paths',
      'Connect with mentors',
      'Find scholarships',
      'AI career coach',
    ],
    route: AppRoutes.signUp,
  ),
  _RoleOption(
    title: 'I\'m a Mentor',
    subtitle: 'Professional or University Graduate',
    description:
    'Share your expertise, guide the next generation of Tanzanian professionals, and build your personal brand.',
    emoji: '🧑‍💼',
    gradient: [Color(0xFF0D9488), Color(0xFF059669)],
    benefits: [
      'Guide students',
      'Build your brand',
      'Flexible scheduling',
      'Grow your network',
    ],
    route: AppRoutes.signUp,
  ),
  _RoleOption(
    title: 'Just Exploring',
    subtitle: 'Browse without an account',
    description:
    'Explore careers, browse opportunities, and see what UniLink offers — no account needed. Sign up anytime.',
    emoji: '👀',
    gradient: [Color(0xFF475569), Color(0xFF334155)],
    benefits: [
      'Browse careers',
      'View opportunities',
      'Read community posts',
      'No commitment',
    ],
    route: AppRoutes.explorePublic,
  ),
];

// ─── Role Selection Screen ────────────────────────────────────────────────

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  int? _selectedIndex;
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  void _selectRole(int index) {
    HapticFeedback.selectionClick();
    setState(() => _selectedIndex = index);
    _backgroundController.forward(from: 0);
  }

  void _proceed() {
    if (_selectedIndex == null) return;
    HapticFeedback.mediumImpact();
    final role = _roles[_selectedIndex!];

    if (_selectedIndex == 0) {
      // Student — go to sign up with student role
      context.push(AppRoutes.signUp, extra: 'student');
    } else if (_selectedIndex == 1) {
      // Mentor — go to sign up with mentor role
      context.push(AppRoutes.signUp, extra: 'mentor');
    } else {
      // Guest — explore without auth
      context.go(AppRoutes.explorePublic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // ─── Animated background tint ──────────────────────────
          if (_selectedIndex != null)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.45,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ..._roles[_selectedIndex!].gradient
                          .map((c) => c.withOpacity(0.15)),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

          // ─── Content ───────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding, 32, AppSpacing.screenPadding, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // UniLink logo pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primaryBlue.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.link_rounded,
                                size: 14,
                                color: AppColors.primaryBlue),
                            const SizedBox(width: 5),
                            Text(
                              'UniLink',
                              style: AppTypography.labelM.copyWith(
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms),

                      const SizedBox(height: 20),

                      Text(
                        'Who are\nyou?',
                        style: AppTypography.displayM.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 500.ms)
                          .slideY(
                          begin: 0.2,
                          end: 0,
                          delay: 100.ms,
                          duration: 500.ms,
                          curve: Curves.easeOut),

                      const SizedBox(height: 8),

                      Text(
                        'Choose your role to get a personalized experience',
                        style: AppTypography.bodyM,
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 500.ms),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Role cards
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                    ),
                    itemCount: _roles.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 14),
                    itemBuilder: (context, index) => _RoleCard(
                      role: _roles[index],
                      isSelected: _selectedIndex == index,
                      onTap: () => _selectRole(index),
                    )
                        .animate()
                        .fadeIn(
                      delay: Duration(milliseconds: 250 + index * 100),
                      duration: 500.ms,
                    )
                        .slideY(
                      begin: 0.15,
                      end: 0,
                      delay: Duration(milliseconds: 250 + index * 100),
                      duration: 500.ms,
                      curve: Curves.easeOut,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Bottom CTA
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    0,
                    AppSpacing.screenPadding,
                    MediaQuery.of(context).padding.bottom + 24,
                  ),
                  child: Column(
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _selectedIndex != null ? 1.0 : 0.4,
                        child: PrimaryButton(
                          label: _selectedIndex == 2
                              ? 'Continue Exploring'
                              : 'Create My Account',
                          onPressed:
                          _selectedIndex != null ? _proceed : null,
                          isDisabled: _selectedIndex == null,
                          trailingIcon: Icons.arrow_forward_rounded,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: AppTypography.bodyS,
                          ),
                          GhostButton(
                            label: 'Sign In',
                            onPressed: () =>
                                context.push(AppRoutes.signIn),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Role Card ────────────────────────────────────────────────────────────

class _RoleCard extends StatefulWidget {
  final _RoleOption role;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _elevationAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _elevationAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? widget.role.gradient.first
                  : AppColors.borderLight,
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
              BoxShadow(
                color: widget.role.gradient.first.withOpacity(0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ]
                : [
              BoxShadow(
                color: AppColors.primaryNavy.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                // ─── Card header ─────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: widget.isSelected
                        ? LinearGradient(
                      colors: widget.role.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : null,
                    color: widget.isSelected
                        ? null
                        : AppColors.surfaceMuted,
                  ),
                  child: Row(
                    children: [
                      // Emoji in circle
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: widget.isSelected
                              ? Colors.white.withOpacity(0.2)
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            widget.role.emoji,
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.role.title,
                              style: AppTypography.h3.copyWith(
                                color: widget.isSelected
                                    ? AppColors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.role.subtitle,
                              style: AppTypography.bodyS.copyWith(
                                color: widget.isSelected
                                    ? AppColors.white.withOpacity(0.8)
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Selection indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isSelected
                              ? AppColors.white
                              : Colors.transparent,
                          border: Border.all(
                            color: widget.isSelected
                                ? Colors.transparent
                                : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: widget.isSelected
                            ? Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: widget.role.gradient.first,
                        )
                            : null,
                      ),
                    ],
                  ),
                ),

                // ─── Card body (benefits) ─────────────────────────
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: _CardBenefits(
                    benefits: widget.role.benefits,
                    color: widget.role.gradient.first,
                    description: widget.role.description,
                  ),
                  crossFadeState: widget.isSelected
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                  firstCurve: Curves.easeIn,
                  secondCurve: Curves.easeOut,
                  sizeCurve: Curves.easeInOut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Card benefits section ────────────────────────────────────────────────

class _CardBenefits extends StatelessWidget {
  final List<String> benefits;
  final Color color;
  final String description;

  const _CardBenefits({
    required this.benefits,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: AppTypography.bodyS,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: benefits.map((benefit) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: color.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 13, color: color),
                    const SizedBox(width: 5),
                    Text(
                      benefit,
                      style: AppTypography.caption.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}