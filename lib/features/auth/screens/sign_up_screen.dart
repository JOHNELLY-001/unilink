import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_spacing.dart';
import '../../../core/enums/user_role.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/ghost_button.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../widgets/auth_header.dart';
import '../widgets/social_sign_in_button.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  /// Pre-selected role passed from Role Selection screen
  final String? preselectedRole;

  const SignUpScreen({super.key, this.preselectedRole});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  late UserRole _selectedRole;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.preselectedRole == 'mentor'
        ? UserRole.mentor
        : UserRole.student;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      _showError('Please agree to the Terms of Service to continue.');
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref.read(authProvider.notifier).signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _nameController.text.trim(),
      role: _selectedRole,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go(AppRoutes.profileSetup);
    } else {
      _showError(ref.read(authProvider).error ??
          'Registration failed. Please try again.');
    }
  }

  Future<void> _googleSignUp() async {
    setState(() => _isGoogleLoading = true);
    final success =
    await ref.read(authProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    setState(() => _isGoogleLoading = false);
    if (success) context.go(AppRoutes.profileSetup);
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

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Full name is required';
    if (v.trim().split(' ').length < 2) return 'Enter your first and last name';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(v)) {
      return 'Include at least one uppercase letter';
    }
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v != _passwordController.text) return 'Passwords do not match';
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
              // ─── Header ──────────────────────────────────────────
              AuthHeader(
                title: 'Create your\naccount ✨',
                subtitle: 'Join thousands of Tanzanian students',
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding, 28,
                    AppSpacing.screenPadding, 0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ─── Role selector ──────────────────────────
                      _RoleSelector(
                        selected: _selectedRole,
                        onChanged: (role) =>
                            setState(() => _selectedRole = role),
                      )
                          .animate()
                          .fadeIn(delay: 100.ms)
                          .slideY(begin: 0.1, end: 0, delay: 100.ms),

                      const SizedBox(height: 24),

                      // ─── Google button ──────────────────────────
                      SocialSignInButton(
                        label: 'Sign up with Google',
                        iconAsset: '',
                        isLoading: _isGoogleLoading,
                        onPressed: _googleSignUp,
                      ).animate().fadeIn(delay: 150.ms),

                      const SizedBox(height: 20),
                      const OrDivider()
                          .animate()
                          .fadeIn(delay: 180.ms),
                      const SizedBox(height: 20),

                      // ─── Full name ───────────────────────────────
                      AppTextField(
                        label: 'Full name',
                        hint: 'Amina Hassan',
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.person_outline_rounded,
                        focusNode: _nameFocus,
                        validator: _validateName,
                        onSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_emailFocus),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 14),

                      // ─── Email ───────────────────────────────────
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
                      ).animate().fadeIn(delay: 230.ms),

                      const SizedBox(height: 14),

                      // ─── Password ────────────────────────────────
                      AppTextField(
                        label: 'Password',
                        hint: '8+ chars, 1 uppercase',
                        controller: _passwordController,
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.lock_outline_rounded,
                        focusNode: _passwordFocus,
                        validator: _validatePassword,
                        onSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_confirmFocus),
                      ).animate().fadeIn(delay: 260.ms),

                      const SizedBox(height: 14),

                      // ─── Confirm password ────────────────────────
                      AppTextField(
                        label: 'Confirm password',
                        hint: 'Repeat your password',
                        controller: _confirmController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        prefixIcon: Icons.lock_outline_rounded,
                        focusNode: _confirmFocus,
                        validator: _validateConfirm,
                        onSubmitted: (_) => _signUp(),
                      ).animate().fadeIn(delay: 290.ms),

                      const SizedBox(height: 20),

                      // ─── Mentor notice ────────────────────────────
                      if (_selectedRole == UserRole.mentor) ...[
                        _MentorNoticeCard()
                            .animate()
                            .fadeIn(duration: 300.ms)
                            .slideY(begin: -0.1, end: 0, duration: 300.ms),
                        const SizedBox(height: 16),
                      ],

                      // ─── Terms checkbox ───────────────────────────
                      _TermsCheckbox(
                        value: _agreedToTerms,
                        onChanged: (v) =>
                            setState(() => _agreedToTerms = v ?? false),
                      ).animate().fadeIn(delay: 320.ms),

                      const SizedBox(height: 24),

                      // ─── Submit button ────────────────────────────
                      PrimaryButton(
                        label: _selectedRole == UserRole.mentor
                            ? 'Apply as Mentor'
                            : 'Create Account',
                        isLoading: _isLoading,
                        onPressed: _signUp,
                      ).animate().fadeIn(delay: 350.ms),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account?',
                              style: AppTypography.bodyS),
                          GhostButton(
                            label: 'Sign In',
                            onPressed: () =>
                                context.pushReplacement(AppRoutes.signIn),
                          ),
                        ],
                      ).animate().fadeIn(delay: 400.ms),

                      SizedBox(
                          height:
                          MediaQuery.of(context).padding.bottom + 28),
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

// ─── Role Selector ────────────────────────────────────────────────────────

class _RoleSelector extends StatelessWidget {
  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  const _RoleSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('I am signing up as', style: AppTypography.labelL),
        const SizedBox(height: 10),
        Row(
          children: [
            _RoleTab(
              label: '🎓 Student',
              isSelected: selected == UserRole.student,
              onTap: () => onChanged(UserRole.student),
            ),
            const SizedBox(width: 10),
            _RoleTab(
              label: '🧑‍💼 Mentor',
              isSelected: selected == UserRole.mentor,
              onTap: () => onChanged(UserRole.mentor),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryBlue
                : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryBlue
                  : AppColors.border,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelL.copyWith(
              color: isSelected
                  ? AppColors.white
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Mentor Notice Card ───────────────────────────────────────────────────

class _MentorNoticeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 18, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mentor applications are reviewed',
                  style: AppTypography.labelM.copyWith(
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Your profile will be reviewed by our team before you can begin mentoring. This usually takes 2–3 business days.',
                  style: AppTypography.caption.copyWith(
                    color: Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Terms Checkbox ───────────────────────────────────────────────────────

class _TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _TermsCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTypography.bodyS,
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: AppTypography.bodyS.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: AppTypography.bodyS.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
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