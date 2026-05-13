import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_spacing.dart';
import '../../../providers/mentor_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/app_bar_widget.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/loaders/app_loader.dart';

class BookSessionScreen extends ConsumerStatefulWidget {
  final String mentorId;

  const BookSessionScreen({super.key, required this.mentorId});

  @override
  ConsumerState<BookSessionScreen> createState() =>
      _BookSessionScreenState();
}

class _BookSessionScreenState
    extends ConsumerState<BookSessionScreen> {
  // Step tracking
  int _step = 0; // 0=select day, 1=select time, 2=topic, 3=confirm

  // Selections
  String? _selectedDay;
  String? _selectedTime;
  final _topicController = TextEditingController();
  final _notesController = TextEditingController();

  // Pre-defined topics
  final _topicOptions = [
    'Career guidance & path planning',
    'University application advice',
    'CV / Resume review',
    'Interview preparation',
    'Technical skills mentoring',
    'Scholarship application help',
    'Industry insights & networking',
    'Other (describe below)',
  ];
  String? _selectedTopic;

  bool _isBooking = false;
  bool _isBooked = false;

  @override
  void dispose() {
    _topicController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _canProceed {
    switch (_step) {
      case 0:
        return _selectedDay != null;
      case 1:
        return _selectedTime != null;
      case 2:
        return _selectedTopic != null;
      case 3:
        return true;
      default:
        return false;
    }
  }

  Future<void> _confirm(String mentorName) async {
    if (!_canProceed) return;
    HapticFeedback.mediumImpact();

    setState(() => _isBooking = true);

    final user = ref.read(currentUserProvider);
    final repo = ref.read(mentorRepositoryProvider);

    // Parse day+time into a DateTime
    final now = DateTime.now();
    final dayOffset = _getDayOffset(_selectedDay!);
    final timeParts = _selectedTime!.split(':');
    final scheduledAt = DateTime(
      now.year,
      now.month,
      now.day + dayOffset,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    await repo.bookSession(
      mentorId: widget.mentorId,
      studentId: user?.id ?? 'usr_001',
      topic: _selectedTopic == 'Other (describe below)'
          ? _topicController.text.trim()
          : _selectedTopic!,
      scheduledAt: scheduledAt,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    ref.invalidate(mySessionsProvider);
    ref.invalidate(upcomingSessionsProvider);

    if (mounted) {
      setState(() {
        _isBooking = false;
        _isBooked = true;
      });
    }
  }

  int _getDayOffset(String day) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday', 'Sunday',
    ];
    final today = DateTime.now().weekday - 1;
    final targetDay = days.indexOf(day);
    int offset = targetDay - today;
    if (offset <= 0) offset += 7;
    return offset;
  }

  @override
  Widget build(BuildContext context) {
    final mentorAsync =
    ref.watch(mentorDetailProvider(widget.mentorId));

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBarWidget(
        title: 'Book a Session',
        showBack: true,
      ),
      body: mentorAsync.when(
        loading: () => const AppLoader(message: 'Loading...'),
        error: (_, __) => const Center(
            child: Text('Could not load mentor')),
        data: (mentor) {
          if (mentor == null) {
            return const Center(
                child: Text('Mentor not found'));
          }

          if (_isBooked) {
            return _SuccessView(
              mentorName: mentor.fullName,
              day: _selectedDay!,
              time: _selectedTime!,
              topic: _selectedTopic == 'Other (describe below)'
                  ? _topicController.text.trim()
                  : _selectedTopic!,
              onDone: () => context.go(AppRoutes.dashboard),
            );
          }

          return Column(
            children: [
              // ─── Progress stepper ──────────────────────────
              _StepIndicator(currentStep: _step),

              // ─── Content ───────────────────────────────────
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) =>
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.06, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        )),
                        child: FadeTransition(
                            opacity: animation, child: child),
                      ),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(
                          AppSpacing.screenPadding),
                      child: _buildStep(mentor),
                    ),
                  ),
                ),
              ),

              // ─── Bottom bar ────────────────────────────────
              _BookingBottomBar(
                step: _step,
                canProceed: _canProceed,
                isBooking: _isBooking,
                onBack: _step > 0
                    ? () => setState(() => _step--)
                    : null,
                onNext: () {
                  if (_step < 3) {
                    setState(() => _step++);
                  } else {
                    _confirm(mentor.fullName);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStep(dynamic mentor) {
    switch (_step) {
      case 0:
        return _SelectDayStep(
          availableDays: mentor.availableDays,
          selectedDay: _selectedDay,
          onDaySelected: (day) =>
              setState(() => _selectedDay = day),
          mentor: mentor,
        );
      case 1:
        return _SelectTimeStep(
          availableSlots: mentor.availableTimeSlots,
          selectedTime: _selectedTime,
          onTimeSelected: (time) =>
              setState(() => _selectedTime = time),
          selectedDay: _selectedDay!,
        );
      case 2:
        return _SelectTopicStep(
          topicOptions: _topicOptions,
          selectedTopic: _selectedTopic,
          topicController: _topicController,
          notesController: _notesController,
          onTopicSelected: (t) =>
              setState(() => _selectedTopic = t),
        );
      case 3:
        return _ConfirmStep(
          mentor: mentor,
          selectedDay: _selectedDay!,
          selectedTime: _selectedTime!,
          selectedTopic: _selectedTopic!,
          topicController: _topicController,
          notesController: _notesController,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Step indicator ───────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  static const _labels = [
    'Pick Day', 'Pick Time', 'Topic', 'Confirm'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 14),
      child: Row(
        children: List.generate(_labels.length, (index) {
          final isActive = index == currentStep;
          final isDone = index < currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isDone
                              ? AppColors.success
                              : isActive
                              ? AppColors.primaryBlue
                              : AppColors.borderLight,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(Icons.check_rounded,
                              size: 14, color: Colors.white)
                              : Text(
                            '${index + 1}',
                            style: AppTypography.caption.copyWith(
                              color: isActive || isDone
                                  ? AppColors.white
                                  : AppColors.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _labels[index],
                        style: AppTypography.caption.copyWith(
                          color: isActive
                              ? AppColors.primaryBlue
                              : AppColors.textMuted,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (index < _labels.length - 1)
                  Container(
                    width: 20,
                    height: 2,
                    color: index < currentStep
                        ? AppColors.success
                        : AppColors.borderLight,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── Step 0: Select Day ───────────────────────────────────────────────────

class _SelectDayStep extends StatelessWidget {
  final List<String> availableDays;
  final String? selectedDay;
  final ValueChanged<String> onDaySelected;
  final dynamic mentor;

  const _SelectDayStep({
    required this.availableDays,
    required this.selectedDay,
    required this.onDaySelected,
    required this.mentor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mentor summary
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              AvatarWidget(
                imageUrl: mentor.avatarUrl,
                name: mentor.fullName,
                size: 44,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mentor.fullName,
                        style: AppTypography.h4),
                    Text(mentor.title,
                        style: AppTypography.caption),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: mentor.isFree
                      ? AppColors.successLight
                      : AppColors.infoLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  mentor.displayPrice,
                  style: AppTypography.labelS.copyWith(
                    color: mentor.isFree
                        ? AppColors.success
                        : AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms),

        const SizedBox(height: 24),

        Text('Select a Day', style: AppTypography.h3)
            .animate()
            .fadeIn(delay: 100.ms),
        const SizedBox(height: 6),
        Text(
          'Choose from the days ${mentor.firstName ?? mentor.fullName.split(' ').first} is available.',
          style: AppTypography.bodyS,
        ).animate().fadeIn(delay: 150.ms),

        const SizedBox(height: 20),

        // Day cards
        ...availableDays.asMap().entries.map((e) {
          final day = e.value;
          final isSelected = selectedDay == day;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => onDaySelected(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
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
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        size: 20,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            day,
                            style: AppTypography.h4.copyWith(
                              color: isSelected
                                  ? AppColors.primaryBlue
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Next: ${_nextOccurrence(day)}',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
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
                          size: 12, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(
                delay: Duration(
                    milliseconds: 200 + e.key * 80),
                duration: 400.ms,
              )
                  .slideX(
                begin: -0.05,
                end: 0,
                delay: Duration(
                    milliseconds: 200 + e.key * 80),
                duration: 400.ms,
              ),
            ),
          );
        }),
      ],
    );
  }

  String _nextOccurrence(String day) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday', 'Sunday',
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final today = DateTime.now().weekday - 1;
    final targetDay = days.indexOf(day);
    int offset = targetDay - today;
    if (offset <= 0) offset += 7;
    final date = DateTime.now().add(Duration(days: offset));
    return '${months[date.month - 1]} ${date.day}';
  }
}

// ─── Step 1: Select Time ──────────────────────────────────────────────────

class _SelectTimeStep extends StatelessWidget {
  final List<String> availableSlots;
  final String? selectedTime;
  final ValueChanged<String> onTimeSelected;
  final String selectedDay;

  const _SelectTimeStep({
    required this.availableSlots,
    required this.selectedTime,
    required this.onTimeSelected,
    required this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '📅 $selectedDay',
                style: AppTypography.labelM.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms),

        const SizedBox(height: 20),

        Text('Select a Time Slot', style: AppTypography.h3)
            .animate()
            .fadeIn(delay: 100.ms),
        const SizedBox(height: 6),
        Text(
          'All times are in East Africa Time (EAT).',
          style: AppTypography.bodyS,
        ).animate().fadeIn(delay: 150.ms),

        const SizedBox(height: 20),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.5,
          children: availableSlots.asMap().entries.map((e) {
            final slot = e.value;
            final isSelected = selectedTime == slot;
            final label = _formatTime(slot);

            return GestureDetector(
              onTap: () => onTimeSelected(slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: AppColors.primaryBlue
                          .withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label.$1,
                      style: AppTypography.h3.copyWith(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      label.$2,
                      style: AppTypography.caption.copyWith(
                        color: isSelected
                            ? AppColors.white.withOpacity(0.8)
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(
                delay: Duration(
                    milliseconds: 150 + e.key * 60),
                duration: 350.ms,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  (String, String) _formatTime(String slot) {
    final parts = slot.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : hour;
    return ('$displayHour:$minute $period', 'EAT');
  }
}

// ─── Step 2: Select Topic ─────────────────────────────────────────────────

class _SelectTopicStep extends StatelessWidget {
  final List<String> topicOptions;
  final String? selectedTopic;
  final TextEditingController topicController;
  final TextEditingController notesController;
  final ValueChanged<String> onTopicSelected;

  const _SelectTopicStep({
    required this.topicOptions,
    required this.selectedTopic,
    required this.topicController,
    required this.notesController,
    required this.onTopicSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What would you like to discuss?',
            style: AppTypography.h3)
            .animate()
            .fadeIn(duration: 400.ms),
        const SizedBox(height: 6),
        Text(
          'This helps your mentor prepare for the session.',
          style: AppTypography.bodyS,
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 20),

        ...topicOptions.asMap().entries.map((e) {
          final topic = e.value;
          final isSelected = selectedTopic == topic;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => onTopicSelected(topic),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue.withOpacity(0.06)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        topic,
                        style: AppTypography.labelL.copyWith(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20,
                      height: 20,
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
                          size: 11, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(
                delay: Duration(
                    milliseconds: 100 + e.key * 50),
                duration: 300.ms,
              ),
            ),
          );
        }),

        // Show custom input for "Other"
        if (selectedTopic == 'Other (describe below)') ...[
          const SizedBox(height: 8),
          AppTextField(
            label: 'Describe your topic',
            hint: 'What do you need help with?',
            controller: topicController,
            maxLines: 3,
          ).animate().fadeIn(duration: 300.ms),
        ],

        const SizedBox(height: 16),

        AppTextField(
          label: 'Additional notes (optional)',
          hint:
          'Any context that will help your mentor prepare...',
          controller: notesController,
          maxLines: 3,
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }
}

// ─── Step 3: Confirm ──────────────────────────────────────────────────────

class _ConfirmStep extends StatelessWidget {
  final dynamic mentor;
  final String selectedDay;
  final String selectedTime;
  final String selectedTopic;
  final TextEditingController topicController;
  final TextEditingController notesController;

  const _ConfirmStep({
    required this.mentor,
    required this.selectedDay,
    required this.selectedTime,
    required this.selectedTopic,
    required this.topicController,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    final displayTopic =
    selectedTopic == 'Other (describe below)'
        ? topicController.text.trim()
        : selectedTopic;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review & Confirm', style: AppTypography.h3)
            .animate()
            .fadeIn(duration: 300.ms),
        const SizedBox(height: 6),
        Text(
          'Double-check your session details before booking.',
          style: AppTypography.bodyS,
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 20),

        // Mentor card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0B1D3A), Color(0xFF1A3A6B)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              AvatarWidget(
                imageUrl: mentor.avatarUrl,
                name: mentor.fullName,
                size: 52,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mentor.fullName,
                      style: AppTypography.h3.copyWith(
                          color: AppColors.white),
                    ),
                    Text(
                      '${mentor.title} @ ${mentor.company}',
                      style: AppTypography.caption.copyWith(
                          color: AppColors.white.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: mentor.isFree
                      ? AppColors.success
                      : AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  mentor.displayPrice,
                  style: AppTypography.labelS.copyWith(
                      color: AppColors.white),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 16),

        // Session details
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: [
              _ConfirmRow(
                icon: Icons.calendar_today_rounded,
                label: 'Day',
                value: selectedDay,
              ),
              const Divider(height: 20),
              _ConfirmRow(
                icon: Icons.access_time_rounded,
                label: 'Time',
                value: '$selectedTime EAT (45 minutes)',
              ),
              const Divider(height: 20),
              _ConfirmRow(
                icon: Icons.topic_rounded,
                label: 'Topic',
                value: displayTopic,
              ),
              if (notesController.text.trim().isNotEmpty) ...[
                const Divider(height: 20),
                _ConfirmRow(
                  icon: Icons.notes_rounded,
                  label: 'Notes',
                  value: notesController.text.trim(),
                ),
              ],
            ],
          ),
        ).animate().fadeIn(delay: 150.ms),

        const SizedBox(height: 14),

        // Info box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.infoLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 18, color: AppColors.primaryBlue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'After booking, ${mentor.firstName ?? mentor.fullName.split(' ').first} will confirm your session and send a meeting link via the UniLink messages.',
                  style: AppTypography.bodyS.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ConfirmRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              size: 18, color: AppColors.primaryBlue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.caption),
              const SizedBox(height: 2),
              Text(value,
                  style: AppTypography.labelL),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Success view ─────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  final String mentorName;
  final String day;
  final String time;
  final String topic;
  final VoidCallback onDone;

  const _SuccessView({
    required this.mentorName,
    required this.day,
    required this.time,
    required this.topic,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        40,
        AppSpacing.screenPadding,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        children: [
          // Celebration icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.success, AppColors.accentTeal],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.4),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Center(
              child: Text('🎉', style: TextStyle(fontSize: 52)),
            ),
          )
              .animate()
              .scale(
            begin: const Offset(0.3, 0.3),
            duration: 700.ms,
            curve: Curves.elasticOut,
          ),

          const SizedBox(height: 28),

          Text(
            'Session Booked!',
            style: AppTypography.displayM,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 10),

          Text(
            '$mentorName has been notified and will confirm your session shortly.',
            style: AppTypography.bodyM,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 32),

          // Summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                _SummaryRow('👤', 'Mentor', mentorName),
                const SizedBox(height: 10),
                _SummaryRow('📅', 'Day', day),
                const SizedBox(height: 10),
                _SummaryRow('🕐', 'Time', '$time EAT'),
                const SizedBox(height: 10),
                _SummaryRow('💬', 'Topic', topic),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms),

          const Spacer(),

          PrimaryButton(
            label: 'Back to Dashboard',
            leadingIcon: Icons.home_rounded,
            onPressed: onDone,
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;

  const _SummaryRow(this.emoji, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Text('$label: ',
            style: AppTypography.caption),
        Expanded(
          child: Text(
            value,
            style: AppTypography.labelM,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Bottom bar ───────────────────────────────────────────────────────────

class _BookingBottomBar extends StatelessWidget {
  final int step;
  final bool canProceed;
  final bool isBooking;
  final VoidCallback? onBack;
  final VoidCallback onNext;

  const _BookingBottomBar({
    required this.step,
    required this.canProceed,
    required this.isBooking,
    required this.onBack,
    required this.onNext,
  });

  String get _buttonLabel {
    if (step < 3) return 'Continue';
    return 'Confirm Booking';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        12,
        AppSpacing.screenPadding,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (onBack != null) ...[
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: PrimaryButton(
              label: _buttonLabel,
              isLoading: isBooking,
              isDisabled: !canProceed,
              onPressed: canProceed ? onNext : null,
              trailingIcon: step < 3
                  ? Icons.arrow_forward_rounded
                  : null,
              height: 50,
            ),
          ),
        ],
      ),
    );
  }
}