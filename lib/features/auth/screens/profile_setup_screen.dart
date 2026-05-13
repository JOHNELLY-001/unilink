import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_gradients.dart';
import '../../../core/enums/education_level.dart';
import '../../../core/enums/user_role.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/ghost_button.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/badges/tag_chip.dart';

// ─── Setup step definitions ───────────────────────────────────────────────

enum _SetupStep { educationOrRole, aboutYou, interests, done }

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen>
    with TickerProviderStateMixin {
  _SetupStep _currentStep = _SetupStep.educationOrRole;

  // Step 1 data
  EducationLevel? _selectedLevel;
  String? _selectedSchool;

  // Step 2 data
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();

  // Step 3 data
  final Set<String> _selectedInterests = {};
  final Set<String> _selectedSkills = {};

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 0.33)
        .animate(CurvedAnimation(
        parent: _progressController, curve: Curves.easeInOut));
    _progressController.forward();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _locationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _nextStep() {
    HapticFeedback.selectionClick();
    final steps = _SetupStep.values;
    final currentIndex = steps.indexOf(_currentStep);

    if (_currentStep == _SetupStep.done) {
      _completeSetup();
      return;
    }

    final nextStep = steps[currentIndex + 1];
    setState(() => _currentStep = nextStep);

    // Animate progress bar
    final nextProgress = (currentIndex + 2) / (_SetupStep.values.length - 1);
    _progressController.animateTo(
      nextProgress.clamp(0.0, 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _prevStep() {
    final steps = _SetupStep.values;
    final currentIndex = steps.indexOf(_currentStep);
    if (currentIndex == 0) return;

    setState(() => _currentStep = steps[currentIndex - 1]);
    final prevProgress = currentIndex / (_SetupStep.values.length - 1);
    _progressController.animateTo(
      prevProgress.clamp(0.0, 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeSetup() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    if (_selectedLevel != null) {
      await ref
          .read(authProvider.notifier)
          .updateEducationLevel(_selectedLevel!);
    }

    await ref.read(authProvider.notifier).completeProfileSetup({
      'bio': _bioController.text.trim(),
      'location': _locationController.text.trim(),
      'interests': _selectedInterests.toList(),
      'skills': _selectedSkills.toList(),
      'school_or_university': _selectedSchool,
    });

    if (mounted) context.go(AppRoutes.dashboard);
  }

  bool get _canProceed {
    switch (_currentStep) {
      case _SetupStep.educationOrRole:
        return true; // optional step
      case _SetupStep.aboutYou:
        return true;
      case _SetupStep.interests:
        return _selectedInterests.isNotEmpty;
      case _SetupStep.done:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isMentor = user?.role == UserRole.mentor;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // ─── Progress header ──────────────────────────────────────
          _ProgressHeader(
            currentStep: _currentStep,
            progressController: _progressController,
            onBack: _currentStep != _SetupStep.educationOrRole
                ? _prevStep
                : null,
          ),

          // ─── Step content ─────────────────────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.08, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  )),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(_currentStep),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    0,
                    AppSpacing.screenPadding,
                    MediaQuery.of(context).padding.bottom + 24,
                  ),
                  child: _buildStep(isMentor),
                ),
              ),
            ),
          ),

          // ─── Bottom CTA ───────────────────────────────────────────
          _BottomBar(
            step: _currentStep,
            canProceed: _canProceed,
            onNext: _nextStep,
            onSkip: _currentStep != _SetupStep.done &&
                _currentStep != _SetupStep.interests
                ? () {
              if (_currentStep == _SetupStep.done) {
                _completeSetup();
              } else {
                _nextStep();
              }
            }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStep(bool isMentor) {
    switch (_currentStep) {
      case _SetupStep.educationOrRole:
        return isMentor
            ? _MentorInfoStep(
          bioController: _bioController,
          locationController: _locationController,
        )
            : _EducationStep(
          selectedLevel: _selectedLevel,
          onLevelSelected: (level) =>
              setState(() => _selectedLevel = level),
          schoolController: TextEditingController(
              text: _selectedSchool ?? ''),
          onSchoolChanged: (v) => _selectedSchool = v,
        );

      case _SetupStep.aboutYou:
        return _AboutYouStep(
          bioController: _bioController,
          locationController: _locationController,
        );

      case _SetupStep.interests:
        return _InterestsStep(
          selectedInterests: _selectedInterests,
          selectedSkills: _selectedSkills,
          onInterestToggled: (interest) => setState(() {
            if (_selectedInterests.contains(interest)) {
              _selectedInterests.remove(interest);
            } else {
              _selectedInterests.add(interest);
            }
          }),
          onSkillToggled: (skill) => setState(() {
            if (_selectedSkills.contains(skill)) {
              _selectedSkills.remove(skill);
            } else {
              _selectedSkills.add(skill);
            }
          }),
        );

      case _SetupStep.done:
        return _AllDoneStep(
          name: ref.watch(currentUserProvider)?.firstName ?? 'there',
          interestCount: _selectedInterests.length,
        );
    }
  }
}

// ─── Progress Header ──────────────────────────────────────────────────────

class _ProgressHeader extends StatelessWidget {
  final _SetupStep currentStep;
  final AnimationController progressController;
  final VoidCallback? onBack;

  const _ProgressHeader({
    required this.currentStep,
    required this.progressController,
    this.onBack,
  });

  String get _stepLabel {
    switch (currentStep) {
      case _SetupStep.educationOrRole:
        return 'Step 1 of 3';
      case _SetupStep.aboutYou:
        return 'Step 2 of 3';
      case _SetupStep.interests:
        return 'Step 3 of 3';
      case _SetupStep.done:
        return 'Complete!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 20),
      decoration: const BoxDecoration(color: AppColors.white),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (onBack != null)
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_ios_rounded,
                        size: 16, color: AppColors.textPrimary),
                  ),
                )
              else
                const SizedBox(width: 38),
              Text(_stepLabel, style: AppTypography.labelM),
              // UniLink logo
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.accentTeal],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.link_rounded,
                    color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          AnimatedBuilder(
            animation: progressController,
            builder: (context, _) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressController.value,
                backgroundColor: AppColors.borderLight,
                valueColor: const AlwaysStoppedAnimation(
                    AppColors.primaryBlue),
                minHeight: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 1A: Education Level ─────────────────────────────────────────────

class _EducationStep extends StatelessWidget {
  final EducationLevel? selectedLevel;
  final ValueChanged<EducationLevel> onLevelSelected;
  final TextEditingController schoolController;
  final ValueChanged<String> onSchoolChanged;

  const _EducationStep({
    required this.selectedLevel,
    required this.onLevelSelected,
    required this.schoolController,
    required this.onSchoolChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text('What is your\neducation level?',
            style: AppTypography.displayM)
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.1, end: 0, duration: 400.ms),

        const SizedBox(height: 8),
        Text(
          'This helps us personalize your experience and show you relevant opportunities.',
          style: AppTypography.bodyM,
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 28),

        ...EducationLevel.values.asMap().entries.map((entry) {
          final index = entry.key;
          final level = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _EducationLevelCard(
              level: level,
              isSelected: selectedLevel == level,
              onTap: () => onLevelSelected(level),
            )
                .animate()
                .fadeIn(
              delay: Duration(milliseconds: 150 + index * 80),
              duration: 400.ms,
            )
                .slideX(
              begin: -0.05,
              end: 0,
              delay: Duration(milliseconds: 150 + index * 80),
              duration: 400.ms,
            ),
          );
        }),

        const SizedBox(height: 20),

        AppTextField(
          label: 'School or University name',
          hint: 'e.g. Kilakala Secondary School',
          controller: schoolController,
          prefixIcon: Icons.school_outlined,
          onChanged: onSchoolChanged,
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }
}

class _EducationLevelCard extends StatelessWidget {
  final EducationLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  const _EducationLevelCard({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  String get _description {
    switch (level) {
      case EducationLevel.form4:
        return 'O-Level studies, preparing for NECTA exams';
      case EducationLevel.form5:
        return 'A-Level first year, choosing your combination';
      case EducationLevel.form6:
        return 'A-Level final year, applying to university';
      case EducationLevel.university:
        return 'Currently enrolled in a university program';
      case EducationLevel.graduate:
        return 'Completed university, working or studying further';
    }
  }

  String get _emoji {
    switch (level) {
      case EducationLevel.form4:
        return '📖';
      case EducationLevel.form5:
        return '📝';
      case EducationLevel.form6:
        return '🎯';
      case EducationLevel.university:
        return '🏛️';
      case EducationLevel.graduate:
        return '🎓';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue.withOpacity(0.06)
              : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(_emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(level.displayName,
                      style: AppTypography.h4.copyWith(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.textPrimary,
                      )),
                  const SizedBox(height: 2),
                  Text(_description,
                      style: AppTypography.caption),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.primaryBlue
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                  size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 1B: Mentor Info ─────────────────────────────────────────────────

class _MentorInfoStep extends StatelessWidget {
  final TextEditingController bioController;
  final TextEditingController locationController;

  const _MentorInfoStep({
    required this.bioController,
    required this.locationController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text('Tell us about\nyourself', style: AppTypography.displayM)
            .animate()
            .fadeIn(duration: 400.ms),
        const SizedBox(height: 8),
        Text(
          'Students will see this information when choosing a mentor.',
          style: AppTypography.bodyM,
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 28),
        AppTextField(
          label: 'Your bio',
          hint:
          'e.g. Senior Software Engineer at Vodacom with 8 years experience...',
          controller: bioController,
          maxLines: 4,
          prefixIcon: Icons.edit_outlined,
          maxLength: 300,
        ).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Location',
          hint: 'e.g. Dar es Salaam, Tanzania',
          controller: locationController,
          prefixIcon: Icons.location_on_outlined,
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }
}

// ─── Step 2: About You ────────────────────────────────────────────────────

class _AboutYouStep extends StatelessWidget {
  final TextEditingController bioController;
  final TextEditingController locationController;

  const _AboutYouStep({
    required this.bioController,
    required this.locationController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text('A bit about\nyou ✍️', style: AppTypography.displayM)
            .animate()
            .fadeIn(duration: 400.ms),
        const SizedBox(height: 8),
        Text(
          'Help mentors and the community know who you are.',
          style: AppTypography.bodyM,
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 28),
        AppTextField(
          label: 'Bio (optional)',
          hint:
          'e.g. Form 6 student passionate about technology and entrepreneurship...',
          controller: bioController,
          maxLines: 3,
          prefixIcon: Icons.edit_outlined,
          maxLength: 200,
        ).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Location',
          hint: 'e.g. Dodoma, Tanzania',
          controller: locationController,
          prefixIcon: Icons.location_on_outlined,
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.infoLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.privacy_tip_outlined,
                  size: 18, color: AppColors.primaryBlue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your location is used to show you local opportunities and relevant mentors. It\'s never shared publicly.',
                  style: AppTypography.caption.copyWith(
                      color: AppColors.primaryBlue),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 250.ms),
      ],
    );
  }
}

// ─── Step 3: Interests & Skills ───────────────────────────────────────────

const _interestOptions = [
  'Software Engineering', 'Data Science', 'Medicine', 'Finance',
  'Business', 'Law', 'Design', 'Engineering', 'Education',
  'Entrepreneurship', 'Cybersecurity', 'AI/ML', 'Nursing',
  'Agriculture', 'Architecture', 'Pharmacy',
];

const _skillOptions = [
  'Mathematics', 'Biology', 'Chemistry', 'Physics',
  'Computer Science', 'Python', 'English', 'Swahili',
  'Accounts', 'Economics', 'History', 'Geography',
];

class _InterestsStep extends StatelessWidget {
  final Set<String> selectedInterests;
  final Set<String> selectedSkills;
  final ValueChanged<String> onInterestToggled;
  final ValueChanged<String> onSkillToggled;

  const _InterestsStep({
    required this.selectedInterests,
    required this.selectedSkills,
    required this.onInterestToggled,
    required this.onSkillToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text('What interests\nyou? 🎯', style: AppTypography.displayM)
            .animate()
            .fadeIn(duration: 400.ms),
        const SizedBox(height: 8),
        Text(
          'Select at least one career interest. This powers your AI recommendations.',
          style: AppTypography.bodyM,
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 24),

        Text('Career interests', style: AppTypography.h4)
            .animate()
            .fadeIn(delay: 150.ms),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _interestOptions.asMap().entries.map((entry) {
            final interest = entry.value;
            return TagChip(
              label: interest,
              isSelected: selectedInterests.contains(interest),
              onTap: () => onInterestToggled(interest),
            )
                .animate()
                .fadeIn(
              delay: Duration(
                  milliseconds: 160 + entry.key * 30),
              duration: 300.ms,
            );
          }).toList(),
        ),

        const SizedBox(height: 28),

        Text('Subjects / Skills', style: AppTypography.h4)
            .animate()
            .fadeIn(delay: 200.ms),
        const SizedBox(height: 4),
        Text('What are your strongest subjects?',
            style: AppTypography.bodyS)
            .animate()
            .fadeIn(delay: 220.ms),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _skillOptions.asMap().entries.map((entry) {
            final skill = entry.value;
            return TagChip(
              label: skill,
              isSelected: selectedSkills.contains(skill),
              onTap: () => onSkillToggled(skill),
              backgroundColor: selectedSkills.contains(skill)
                  ? null
                  : AppColors.surfaceMuted,
            )
                .animate()
                .fadeIn(
              delay: Duration(
                  milliseconds: 250 + entry.key * 30),
              duration: 300.ms,
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        if (selectedInterests.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColors.warning),
                const SizedBox(width: 8),
                Text(
                  'Select at least one career interest to continue.',
                  style: AppTypography.caption.copyWith(
                      color: Color(0xFF92400E)),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),
      ],
    );
  }
}

// ─── Step 4: All Done ─────────────────────────────────────────────────────

class _AllDoneStep extends StatelessWidget {
  final String name;
  final int interestCount;

  const _AllDoneStep({
    required this.name,
    required this.interestCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),

        // Celebration illustration
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.accentTeal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.4),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Center(
            child: Text('🎉', style: TextStyle(fontSize: 56)),
          ),
        )
            .animate()
            .scale(
          begin: const Offset(0.3, 0.3),
          duration: 700.ms,
          curve: Curves.elasticOut,
        )
            .fadeIn(duration: 300.ms),

        const SizedBox(height: 32),

        Text(
          'You\'re all set,\n$name!',
          style: AppTypography.displayM,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),

        const SizedBox(height: 12),

        Text(
          'Your profile is ready. UniLink AI is now personalizing your experience based on your $interestCount interest${interestCount != 1 ? 's' : ''}.',
          style: AppTypography.bodyM,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms),

        const SizedBox(height: 36),

        // What's waiting cards
        ...[
          ('🤖', 'AI Career Coach', 'Ready to answer any question'),
          ('🤝', 'Matched Mentors', 'Based on your interests'),
          ('🎓', 'Scholarships', 'Relevant to your profile'),
        ].asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _WaitingCard(
              emoji: item.$1,
              title: item.$2,
              subtitle: item.$3,
            )
                .animate()
                .fadeIn(
              delay: Duration(milliseconds: 500 + index * 100),
              duration: 400.ms,
            )
                .slideX(
              begin: 0.05,
              end: 0,
              delay: Duration(milliseconds: 500 + index * 100),
              duration: 400.ms,
            ),
          );
        }),
      ],
    );
  }
}

class _WaitingCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _WaitingCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.h4),
              Text(subtitle, style: AppTypography.caption),
            ],
          ),
          const Spacer(),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.check_rounded,
                size: 16, color: AppColors.success),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Bar ───────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final _SetupStep step;
  final bool canProceed;
  final VoidCallback onNext;
  final VoidCallback? onSkip;

  const _BottomBar({
    required this.step,
    required this.canProceed,
    required this.onNext,
    this.onSkip,
  });

  String get _buttonLabel {
    switch (step) {
      case _SetupStep.educationOrRole:
        return 'Continue';
      case _SetupStep.aboutYou:
        return 'Continue';
      case _SetupStep.interests:
        return 'Continue';
      case _SetupStep.done:
        return 'Explore UniLink 🚀';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        16,
        AppSpacing.screenPadding,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            label: _buttonLabel,
            onPressed: canProceed ? onNext : null,
            isDisabled: !canProceed,
            trailingIcon: step != _SetupStep.done
                ? Icons.arrow_forward_rounded
                : null,
          ),
          if (onSkip != null) ...[
            const SizedBox(height: 10),
            GhostButton(
              label: 'Skip this step',
              color: AppColors.textMuted,
              onPressed: onSkip,
            ),
          ],
        ],
      ),
    );
  }
}