import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_spacing.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/ghost_button.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/app_bar_widget.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await ref
        .read(authProvider.notifier)
        .forgotPassword(_emailController.text.trim());

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _emailSent = success;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBarWidget(
        title: 'Reset Password',
        showBack: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            32,
            AppSpacing.screenPadding,
            MediaQuery.of(context).padding.bottom + 24,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: _emailSent
                ? _SuccessView(
              email: _emailController.text.trim(),
              onBack: () => Navigator.pop(context),
              onResend: _sendReset,
            )
                : _FormView(
              formKey: _formKey,
              emailController: _emailController,
              isLoading: _isLoading,
              onSubmit: _sendReset,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Form View ────────────────────────────────────────────────────────────

class _FormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _FormView({
    required this.formKey,
    required this.emailController,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                size: 40,
                color: AppColors.primaryBlue,
              ),
            ).animate().scale(
              begin: const Offset(0.5, 0.5),
              duration: 500.ms,
              curve: Curves.elasticOut,
            ),
          ),

          const SizedBox(height: 28),

          Text(
            'Forgot your\npassword?',
            style: AppTypography.displayM,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 12),

          Text(
            "No worries! Enter your email and we'll send you a link to reset your password.",
            style: AppTypography.bodyM,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 36),

          AppTextField(
            label: 'Email address',
            hint: 'you@example.com',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.mail_outline_rounded,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required';
              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(v)) {
                return 'Enter a valid email address';
              }
              return null;
            },
            onSubmitted: (_) => onSubmit(),
          ).animate().fadeIn(delay: 250.ms),

          const SizedBox(height: 28),

          PrimaryButton(
            label: 'Send Reset Link',
            isLoading: isLoading,
            leadingIcon: Icons.send_rounded,
            onPressed: onSubmit,
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 20),

          Center(
            child: GhostButton(
              label: '← Back to Sign In',
              color: AppColors.textMuted,
              onPressed: () => Navigator.pop(context),
            ),
          ).animate().fadeIn(delay: 350.ms),
        ],
      ),
    );
  }
}

// ─── Success View ─────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  final String email;
  final VoidCallback onBack;
  final VoidCallback onResend;

  const _SuccessView({
    required this.email,
    required this.onBack,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success icon
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              size: 40,
              color: AppColors.success,
            ),
          )
              .animate()
              .scale(
            begin: const Offset(0.4, 0.4),
            duration: 600.ms,
            curve: Curves.elasticOut,
          )
              .fadeIn(duration: 300.ms),
        ),

        const SizedBox(height: 28),

        Text(
          'Check your\ninbox 📬',
          style: AppTypography.displayM,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 12),

        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTypography.bodyM,
            children: [
              const TextSpan(
                  text: "We've sent a password reset link to\n"),
              TextSpan(
                text: email,
                style: AppTypography.bodyM.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms),

        const SizedBox(height: 32),

        // Tip card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.infoLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded,
                  size: 20, color: AppColors.primaryBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Didn't receive it? Check your spam folder, or wait a moment and try resending.",
                  style: AppTypography.bodyS.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 350.ms),

        const SizedBox(height: 32),

        PrimaryButton(
          label: 'Back to Sign In',
          onPressed: onBack,
        ).animate().fadeIn(delay: 400.ms),

        const SizedBox(height: 16),

        Center(
          child: GhostButton(
            label: 'Resend email',
            color: AppColors.textMuted,
            onPressed: onResend,
          ),
        ).animate().fadeIn(delay: 450.ms),
      ],
    );
  }
}