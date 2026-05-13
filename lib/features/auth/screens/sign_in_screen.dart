import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_spacing.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/ghost_button.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../widgets/auth_header.dart';
import '../widgets/social_sign_in_button.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await ref.read(authProvider.notifier).signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go(AppRoutes.dashboard);
    } else {
      _showError(ref.read(authProvider).error ??
          'Sign in failed. Please try again.');
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _isGoogleLoading = true);
    final success =
    await ref.read(authProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    setState(() => _isGoogleLoading = false);

    if (success) {
      context.go(AppRoutes.dashboard);
    } else {
      _showError('Google sign in failed. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String? _validateEmail(String? val) {
    if (val == null || val.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(val)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? val) {
    if (val == null || val.isEmpty) return 'Password is required';
    if (val.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Header ────────────────────────────────────────────
              AuthHeader(
                title: 'Welcome\nback 👋',
                subtitle: 'Sign in to continue your journey',
              ),

              // ─── Form ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  32,
                  AppSpacing.screenPadding,
                  0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Google sign in
                      SocialSignInButton(
                        label: 'Continue with Google',
                        iconAsset: '',
                        isLoading: _isGoogleLoading,
                        onPressed: _googleSignIn,
                      ).animate().fadeIn(delay: 100.ms).slideY(
                        begin: 0.1,
                        end: 0,
                        delay: 100.ms,
                        duration: 400.ms,
                      ),

                      const SizedBox(height: 24),
                      const OrDivider()
                          .animate()
                          .fadeIn(delay: 150.ms),
                      const SizedBox(height: 24),

                      // Email
                      AppTextField(
                        label: 'Email address',
                        hint: 'you@example.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.mail_outline_rounded,
                        focusNode: _emailFocus,
                        validator: _validateEmail,
                        onSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_passwordFocus),
                      ).animate().fadeIn(delay: 200.ms).slideY(
                        begin: 0.1,
                        end: 0,
                        delay: 200.ms,
                        duration: 400.ms,
                      ),

                      const SizedBox(height: 16),

                      // Password
                      AppTextField(
                        label: 'Password',
                        hint: '••••••••',
                        controller: _passwordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        prefixIcon: Icons.lock_outline_rounded,
                        focusNode: _passwordFocus,
                        validator: _validatePassword,
                        onSubmitted: (_) => _signIn(),
                      ).animate().fadeIn(delay: 250.ms).slideY(
                        begin: 0.1,
                        end: 0,
                        delay: 250.ms,
                        duration: 400.ms,
                      ),

                      const SizedBox(height: 10),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: GhostButton(
                          label: 'Forgot password?',
                          onPressed: () =>
                              context.push(AppRoutes.forgotPassword),
                        ),
                      ).animate().fadeIn(delay: 300.ms),

                      const SizedBox(height: 28),

                      // Sign In button
                      PrimaryButton(
                        label: 'Sign In',
                        isLoading: _isLoading,
                        onPressed: _signIn,
                      ).animate().fadeIn(delay: 350.ms).slideY(
                        begin: 0.1,
                        end: 0,
                        delay: 350.ms,
                        duration: 400.ms,
                      ),

                      const SizedBox(height: 28),

                      // Sign up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: AppTypography.bodyS,
                          ),
                          GhostButton(
                            label: 'Sign Up',
                            onPressed: () =>
                                context.push(AppRoutes.signUp),
                          ),
                        ],
                      ).animate().fadeIn(delay: 400.ms),

                      const SizedBox(height: 20),

                      // Guest explore
                      Center(
                        child: GhostButton(
                          label: 'Continue as Guest →',
                          color: AppColors.textMuted,
                          onPressed: () =>
                              context.go(AppRoutes.explorePublic),
                        ),
                      ).animate().fadeIn(delay: 450.ms),

                      SizedBox(
                          height:
                          MediaQuery.of(context).padding.bottom + 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}