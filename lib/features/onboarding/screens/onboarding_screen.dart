import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../widgets/onboarding_page_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() {
        _currentPage = page;
        _isLastPage = page == onboardingPages.length - 1;
      });
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingComplete, true);
    if (mounted) context.go(AppRoutes.roleSelection);
  }

  void _nextPage() {
    if (_isLastPage) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ─── Page view ─────────────────────────────────────────────
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingPages.length,
            itemBuilder: (context, index) => OnboardingPageWidget(
              data: onboardingPages[index],
              isActive: index == _currentPage,
            ),
          ),

          // ─── Skip button (top right) ────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 20,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isLastPage ? 0.0 : 1.0,
              child: GestureDetector(
                onTap: _completeOnboarding,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    'Skip',
                    style: AppTypography.labelM.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 800.ms),
          ),

          // ─── Bottom controls ────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomControls(
              currentPage: _currentPage,
              totalPages: onboardingPages.length,
              isLastPage: _isLastPage,
              pageController: _pageController,
              onNext: _nextPage,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Controls ──────────────────────────────────────────────────────

class _BottomControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool isLastPage;
  final PageController pageController;
  final VoidCallback onNext;

  const _BottomControls({
    required this.currentPage,
    required this.totalPages,
    required this.isLastPage,
    required this.pageController,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        28,
        24,
        28,
        MediaQuery.of(context).padding.bottom + 28,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Page indicator dots
          SmoothPageIndicator(
            controller: pageController,
            count: totalPages,
            effect: WormEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: AppColors.white,
              dotColor: AppColors.white.withOpacity(0.3),
              spacing: 8,
              type: WormType.thinUnderground,
            ),
          ),

          // Next / Get Started button
          GestureDetector(
            onTap: onNext,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(
                horizontal: isLastPage ? 28 : 20,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isLastPage
                        ? Text(
                      'Get Started',
                      key: const ValueKey('started'),
                      style: AppTypography.buttonM.copyWith(
                        color: AppColors.primaryBlue,
                      ),
                    )
                        : const SizedBox.shrink(
                      key: ValueKey('empty'),
                    ),
                  ),
                  if (isLastPage) const SizedBox(width: 8),
                  Icon(
                    isLastPage
                        ? Icons.arrow_forward_rounded
                        : Icons.chevron_right_rounded,
                    color: AppColors.primaryBlue,
                    size: isLastPage ? 20 : 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}