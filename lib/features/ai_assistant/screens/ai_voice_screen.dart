import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_gradients.dart';

class AiVoiceScreen extends StatefulWidget {
  const AiVoiceScreen({super.key});

  @override
  State<AiVoiceScreen> createState() => _AiVoiceScreenState();
}

class _AiVoiceScreenState extends State<AiVoiceScreen>
    with TickerProviderStateMixin {
  bool _isListening = false;
  bool _isProcessing = false;
  String _transcript = '';
  String _aiResponse = '';

  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;

  final _waveHeights = [
    0.2, 0.5, 0.8, 0.4, 0.9, 0.3, 0.7,
    0.5, 0.6, 0.4, 0.8, 0.3, 0.6, 0.9, 0.4,
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15)
        .animate(CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _toggleListening() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isListening = !_isListening;
      _transcript = '';
      _aiResponse = '';
    });

    if (_isListening) {
      _pulseController.repeat(reverse: true);
      _waveController.repeat(reverse: true);
      // Simulate transcript after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _isListening) {
          setState(() {
            _transcript =
            'I want to learn about software engineering careers in Tanzania';
          });
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) _processVoice();
          });
        }
      });
    } else {
      _pulseController.stop();
      _waveController.stop();
    }
  }

  void _processVoice() {
    setState(() {
      _isListening = false;
      _isProcessing = true;
    });
    _pulseController.stop();
    _waveController.stop();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _aiResponse =
          'Software Engineering is Tanzania\'s fastest-growing career! I recommend starting with Python, exploring UDSM\'s BSc Computer Science, and checking Grace Kimaro\'s mentor profile. Salary ranges from TZS 1.2M entry-level to 8M+ senior.';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B1D3A), Color(0xFF0D2E4F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ─── Header ───────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    16, 16, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Voice Assistant',
                      style: AppTypography.h3.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              const Spacer(),

              // ─── Waveform / Status ─────────────────────
              if (_isListening)
                _WaveformDisplay(
                  waveController: _waveController,
                  waveHeights: _waveHeights,
                )
              else if (_isProcessing)
                _ProcessingDisplay()
              else if (_aiResponse.isNotEmpty)
                  _ResponseDisplay(response: _aiResponse)
                else
                  _IdleDisplay(),

              const Spacer(),

              // ─── Transcript ────────────────────────────
              if (_transcript.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color:
                          Colors.white.withOpacity(0.12)),
                    ),
                    child: Text(
                      '"$_transcript"',
                      style: AppTypography.bodyM.copyWith(
                        color: AppColors.white.withOpacity(0.85),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 32),

              // ─── Main mic button ───────────────────────
              GestureDetector(
                onTap: _isProcessing ? null : _toggleListening,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _isListening
                        ? _pulseAnimation.value
                        : 1.0,
                    child: child,
                  ),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: _isListening
                          ? const LinearGradient(
                        colors: [
                          AppColors.error,
                          Color(0xFFFF6B6B),
                        ],
                      )
                          : AppGradients.heroBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening
                              ? AppColors.error
                              : AppColors.primaryBlue)
                              .withOpacity(0.5),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening
                          ? Icons.stop_rounded
                          : Icons.mic_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ),
              )
                  .animate()
                  .scale(
                begin: const Offset(0.6, 0.6),
                duration: 600.ms,
                curve: Curves.elasticOut,
              )
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 16),

              // Status text
              Text(
                _isProcessing
                    ? 'Processing your voice...'
                    : _isListening
                    ? 'Listening... tap to stop'
                    : _aiResponse.isNotEmpty
                    ? 'Tap mic to ask again'
                    : 'Tap the mic and speak',
                style: AppTypography.bodyM.copyWith(
                  color: AppColors.white.withOpacity(0.7),
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Waveform display ─────────────────────────────────────────────────────

class _WaveformDisplay extends StatelessWidget {
  final AnimationController waveController;
  final List<double> waveHeights;

  const _WaveformDisplay({
    required this.waveController,
    required this.waveHeights,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          '🎙️',
          style: TextStyle(fontSize: 48),
        ).animate().fadeIn(),
        const SizedBox(height: 20),
        AnimatedBuilder(
          animation: waveController,
          builder: (context, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: waveHeights.asMap().entries.map((e) {
                final i = e.key;
                final baseHeight = e.value;
                final animatedHeight = baseHeight +
                    (waveController.value *
                        (1 - baseHeight) *
                        0.5 *
                        ((i % 3 == 0) ? 1 : -1));
                return Container(
                  width: 4,
                  height: 60 * animatedHeight.abs(),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primaryBlue,
                        AppColors.accentTeal,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Listening...',
          style: AppTypography.h3.copyWith(
            color: AppColors.white,
          ),
        ).animate().fadeIn(),
      ],
    );
  }
}

class _ProcessingDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(
                AppColors.accentTealLight),
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'UniLink AI is thinking...',
          style: AppTypography.h3.copyWith(
            color: AppColors.white,
          ),
        ),
      ],
    ).animate().fadeIn();
  }
}

class _ResponseDisplay extends StatelessWidget {
  final String response;

  const _ResponseDisplay({required this.response});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: AppGradients.heroBlue,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.smart_toy_rounded,
                      color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  'UniLink AI',
                  style: AppTypography.labelL.copyWith(
                    color: AppColors.accentTealLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              response,
              style: AppTypography.bodyM.copyWith(
                color: AppColors.white.withOpacity(0.85),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(
      begin: 0.1,
      end: 0,
      delay: 200.ms,
      duration: 400.ms,
    );
  }
}

class _IdleDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('🎙️',
            style: TextStyle(fontSize: 56))
            .animate()
            .scale(
          begin: const Offset(0.5, 0.5),
          duration: 600.ms,
          curve: Curves.elasticOut,
        ),
        const SizedBox(height: 16),
        Text(
          'Voice Assistant',
          style: AppTypography.h2.copyWith(
            color: AppColors.white,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 8),
        Text(
          'Ask about careers, universities,\nscholarships, or get a mentor',
          style: AppTypography.bodyM.copyWith(
            color: AppColors.white.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }
}