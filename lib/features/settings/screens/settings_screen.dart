import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_gradients.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/app_bar_widget.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/badges/premium_badge.dart';
import '../../../shared/widgets/dialogs/confirmation_dialog.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Toggle states
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _sessionReminders = true;
  bool _communityAlerts = true;
  bool _scholarshipAlerts = true;
  bool _aiSuggestions = true;
  bool _voiceAssistant = false;
  bool _dataCollection = true;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBarWidget(
        title: 'Settings',
        showBack: true,
      ),
      body: ListView(
        children: [
          // ─── Profile summary ───────────────────────────
          _ProfileSummaryCard(user: user)
              .animate()
              .fadeIn(delay: 50.ms),

          const SizedBox(height: 8),

          // ─── Account ───────────────────────────────────
          _SettingsGroup(
            title: 'Account',
            children: [
              _SettingsTile(
                icon: Icons.person_outline_rounded,
                label: 'Edit Profile',
                color: AppColors.primaryBlue,
                onTap: () => context.push(AppRoutes.profile),
              ),
              _SettingsTile(
                icon: Icons.school_outlined,
                label: 'Education Level',
                color: AppColors.accentTeal,
                trailing: Text(
                  user?.educationLevel?.displayName ?? 'Not set',
                  style: AppTypography.bodyS
                      .copyWith(color: AppColors.textMuted),
                ),
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.lock_outline_rounded,
                label: 'Change Password',
                color: AppColors.textSecondary,
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.mail_outline_rounded,
                label: 'Email Address',
                color: AppColors.textSecondary,
                trailing: Text(
                  user?.email ?? '',
                  style: AppTypography.caption,
                ),
                onTap: () {},
              ),
            ],
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 8),

          // ─── Notifications ─────────────────────────────
          _SettingsGroup(
            title: 'Notifications',
            children: [
              _ToggleTile(
                icon: Icons.notifications_outlined,
                label: 'Push Notifications',
                color: AppColors.primaryBlue,
                value: _pushNotifications,
                onChanged: (v) =>
                    setState(() => _pushNotifications = v),
              ),
              _ToggleTile(
                icon: Icons.mail_outline_rounded,
                label: 'Email Notifications',
                color: AppColors.accentTeal,
                value: _emailNotifications,
                onChanged: (v) =>
                    setState(() => _emailNotifications = v),
              ),
              _ToggleTile(
                icon: Icons.alarm_outlined,
                label: 'Session Reminders',
                color: AppColors.premiumGold,
                value: _sessionReminders,
                onChanged: (v) =>
                    setState(() => _sessionReminders = v),
              ),
              _ToggleTile(
                icon: Icons.forum_outlined,
                label: 'Community Alerts',
                color: AppColors.premiumPurple,
                value: _communityAlerts,
                onChanged: (v) =>
                    setState(() => _communityAlerts = v),
              ),
              _ToggleTile(
                icon: Icons.school_outlined,
                label: 'Scholarship Alerts',
                color: AppColors.success,
                value: _scholarshipAlerts,
                onChanged: (v) =>
                    setState(() => _scholarshipAlerts = v),
              ),
            ],
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 8),

          // ─── AI Preferences ────────────────────────────
          _SettingsGroup(
            title: 'AI & Personalization',
            children: [
              _ToggleTile(
                icon: Icons.smart_toy_outlined,
                label: 'AI Suggestions',
                subtitle: 'Personalized career & mentor recs',
                color: AppColors.primaryBlue,
                value: _aiSuggestions,
                onChanged: (v) =>
                    setState(() => _aiSuggestions = v),
              ),
              _ToggleTile(
                icon: Icons.mic_outlined,
                label: 'Voice Assistant',
                subtitle: 'Interact with UniLink AI by voice',
                color: AppColors.accentTeal,
                value: _voiceAssistant,
                onChanged: (v) =>
                    setState(() => _voiceAssistant = v),
              ),
              _ToggleTile(
                icon: Icons.analytics_outlined,
                label: 'Usage Analytics',
                subtitle: 'Help improve UniLink',
                color: AppColors.textSecondary,
                value: _dataCollection,
                onChanged: (v) =>
                    setState(() => _dataCollection = v),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 8),

          // ─── Subscription ──────────────────────────────
          _SettingsGroup(
            title: 'Subscription',
            children: [
              _SettingsTile(
                icon: Icons.auto_awesome_rounded,
                label: user?.isPro == true
                    ? 'UniLink Pro — Active'
                    : 'Upgrade to Pro',
                color: AppColors.premiumGold,
                trailing: user?.isPro == true
                    ? const PremiumBadge(small: true)
                    : Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: AppGradients.premium,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Upgrade',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                onTap: () => context.push(AppRoutes.upgrade),
              ),
              _SettingsTile(
                icon: Icons.receipt_long_outlined,
                label: 'Billing History',
                color: AppColors.textSecondary,
                onTap: () {},
              ),
            ],
          ).animate().fadeIn(delay: 250.ms),

          const SizedBox(height: 8),

          // ─── Support & Legal ───────────────────────────
          _SettingsGroup(
            title: 'Support & Legal',
            children: [
              _SettingsTile(
                icon: Icons.help_outline_rounded,
                label: 'Help Center',
                color: AppColors.primaryBlue,
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                color: AppColors.textSecondary,
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                label: 'Terms of Service',
                color: AppColors.textSecondary,
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                label: 'App Version',
                color: AppColors.textMuted,
                trailing: Text(
                  'v1.0.0',
                  style: AppTypography.caption,
                ),
                onTap: () {},
              ),
            ],
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 8),

          // ─── Danger zone ───────────────────────────────
          _SettingsGroup(
            title: 'Account Actions',
            children: [
              _SettingsTile(
                icon: Icons.logout_rounded,
                label: 'Sign Out',
                color: AppColors.error,
                labelColor: AppColors.error,
                onTap: () async {
                  final confirm = await ConfirmationDialog.show(
                    context,
                    title: 'Sign Out',
                    message:
                    'Are you sure you want to sign out?',
                    confirmLabel: 'Sign Out',
                    cancelLabel: 'Cancel',
                    isDestructive: true,
                  );
                  if (confirm == true && context.mounted) {
                    await ref
                        .read(authProvider.notifier)
                        .signOut();
                    if (context.mounted) {
                      context.go(AppRoutes.signIn);
                    }
                  }
                },
              ),
              _SettingsTile(
                icon: Icons.delete_outline_rounded,
                label: 'Delete Account',
                color: AppColors.error,
                labelColor: AppColors.error,
                onTap: () async {
                  await ConfirmationDialog.show(
                    context,
                    title: 'Delete Account',
                    message:
                    'This action is permanent and cannot be undone. All your data will be deleted.',
                    confirmLabel: 'Delete Account',
                    cancelLabel: 'Keep Account',
                    isDestructive: true,
                  );
                },
              ),
            ],
          ).animate().fadeIn(delay: 350.ms),

          // Footer
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              24,
              AppSpacing.screenPadding,
              MediaQuery.of(context).padding.bottom + 24,
            ),
            child: Column(
              children: [
                Text(
                  'UniLink v1.0.0',
                  style: AppTypography.caption,
                ),
                const SizedBox(height: 4),
                Text(
                  'Made with ❤️ in Tanzania 🇹🇿',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}

// ─── Profile summary card ─────────────────────────────────────────────────

class _ProfileSummaryCard extends StatelessWidget {
  final dynamic user;

  const _ProfileSummaryCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.screenPadding),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.heroNavy,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          AvatarWidget(
            imageUrl: user?.avatarUrl,
            name: user?.fullName ?? 'User',
            size: 52,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? 'Your Name',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? '',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.white.withOpacity(0.65),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user?.planId?.toUpperCase() == 'FREE'
                        ? 'Free Plan'
                        : 'Pro Member',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

// ─── Settings group ───────────────────────────────────────────────────────

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 4, bottom: 8, top: 4),
            child: Text(
              title.toUpperCase(),
              style: AppTypography.labelS,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: children.asMap().entries.map((e) {
                final isLast = e.key == children.length - 1;
                return Column(
                  children: [
                    e.value,
                    if (!isLast)
                      const Divider(
                        height: 1,
                        indent: 56,
                        color: AppColors.borderLight,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Settings tile ────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color? labelColor;
  final Widget? trailing;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.color,
    this.labelColor,
    this.trailing,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelL.copyWith(
                      color:
                      labelColor ?? AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: AppTypography.caption),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ] else
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 13, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

// ─── Toggle tile ──────────────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.labelL),
                if (subtitle != null)
                  Text(subtitle!, style: AppTypography.caption),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryBlue,
            materialTapTargetSize:
            MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}