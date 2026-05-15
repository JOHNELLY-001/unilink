import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../providers/auth_provider.dart';
import 'route_guards.dart';
import 'package:unilink/features/shell/app_shell.dart';
import '../features/splash/splash_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/onboarding/screens/role_selection_screen.dart';
import '../features/auth/screens/sign_in_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/profile_setup_screen.dart';
import '../features/explore/screens/explore_home_screen.dart';
import '../features/dashboard/screens/student_dashboard.dart';
import '../features/dashboard/screens/mentor_dashboard.dart';
import '../features/shell/app_shell.dart';
import '../core/enums/user_role.dart';
import '../features/careers/screens/careers_screen.dart';
import '../features/careers/screens/career_detail_screen.dart';
import '../features/mentors/screens/mentors_screen.dart';
import '../features/mentors/screens/mentor_detail_screen.dart';
import '../features/mentors/screens/book_session_screen.dart';
import '../features/community/screens/community_screen.dart';
import '../features/opportunities/screens/opportunity_screen.dart';
import '../features/resources/screens/resources_screen.dart';
import '../features/messages/screens/messages_screen.dart';
import '../features/messages/screens/chat_screen.dart';
import '../features/progress/screens/progress_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/ai_assistant/screens/ai_chat_screen.dart';
import '../features/ai_assistant/screens/ai_voice_screen.dart';
import '../features/premium/screens/upgrade_screen.dart';



// ─── Placeholder screens (replaced round by round) ───────────────────────────
// Each will be swapped out as we build the real screens in subsequent rounds.
// This keeps the app runnable after Round 1.
class _PlaceholderScreen extends StatelessWidget {
  final String label;
  const _PlaceholderScreen(this.label);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(
        child: Text(
          label,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

// In lib/routes/app_router.dart
// Replace the appRouterProvider with this version:

final appRouterProvider = Provider<GoRouter>((ref) {
  // Watch auth state so router rebuilds on login/logout
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      return evaluateRedirect(
        state: state,
        authState: authState,
      );
    },
    routes: _buildRoutes(),
  );
});

List<RouteBase> _buildRoutes() {
  return [
    // ─── Public Routes ──────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(), // ← real screen
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(), // ← real screen
    ),
    GoRoute(
      path: AppRoutes.roleSelection,
      name: 'roleSelection',
      builder: (context, state) => const RoleSelectionScreen(), // ← real screen
    ),
    GoRoute(
      path: AppRoutes.explorePublic,
      name: 'explorePublic',
      builder: (context, state) => const ExploreHomeScreen(),
    ),

    // ─── Auth Routes ─────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.signIn,
      name: 'signIn',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: AppRoutes.signUp,
      name: 'signUp',
      builder: (context, state) {
        // Receives 'student' or 'mentor' from role selection
        final role = state.extra as String?;
        return SignUpScreen(preselectedRole: role);
      },
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgotPassword',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.profileSetup,
      name: 'profileSetup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),

    // ─── Main Shell (ShellRoute for bottom nav) ──────────────────────────
    // TODO: Replace _PlaceholderScreen with real AppShell in Round 4
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(child: child); // ← replaces the plain Scaffold
      },
      routes: [

// Replace the dashboard GoRoute inside ShellRoute:
        GoRoute(
          path: AppRoutes.dashboard,
          name: 'dashboard',
          builder: (context, state) {
            // Smart router: picks dashboard based on user role
            // Read role directly from provider
            return Consumer(
              builder: (context, ref, _) {
                final role = ref.watch(userRoleProvider);
                return role == UserRole.mentor
                    ? const MentorDashboard()
                    : const StudentDashboard();
              },
            );
          },
        ),
            // Replace careers GoRoute inside ShellRoute:
            GoRoute(
              path: AppRoutes.careers,
              name: 'careers',
              builder: (context, state) => const CareersScreen(),
              routes: [
                GoRoute(
                  path: ':careerId',
                  name: 'careerDetail',
                  builder: (context, state) {
                    final careerId = state.pathParameters['careerId']!;
                    return CareerDetailScreen(careerId: careerId);
                  },
                ),
              ],
            ),

        // Replace mentor routes inside ShellRoute:
        GoRoute(
          path: AppRoutes.mentors,
          name: 'mentors',
          builder: (context, state) => const MentorsScreen(),
          routes: [
            GoRoute(
              path: ':mentorId',
              name: 'mentorDetail',
              builder: (context, state) {
                final mentorId = state.pathParameters['mentorId']!;
                return MentorDetailScreen(mentorId: mentorId);
              },
              routes: [
                GoRoute(
                  path: 'book',
                  name: 'bookSession',
                  builder: (context, state) {
                    final mentorId = state.pathParameters['mentorId']!;
                    return BookSessionScreen(mentorId: mentorId);
                  },
                ),
              ],
            ),
          ],
        ),
        // Replace AI and upgrade GoRoutes inside ShellRoute:
        GoRoute(
          path: AppRoutes.aiAssistant,
          name: 'aiAssistant',
          builder: (context, state) => const AiChatScreen(),
          routes: [
            GoRoute(
              path: 'voice',
              name: 'aiVoice',
              builder: (context, state) => const AiVoiceScreen(),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.community,
          name: 'community',
          builder: (context, state) => const CommunityScreen(),
        ),

        GoRoute(
          path: AppRoutes.opportunities,
          name: 'opportunities',
          builder: (context, state) => const OpportunitiesScreen(),
          routes: [
            GoRoute(
              path: ':opportunityId',
              name: 'opportunityDetail',
              builder: (context, state) {
                // Full detail screen — built in a later round if needed
                // For now shows opportunity list card expanded
                final id = state.pathParameters['opportunityId']!;
                return _PlaceholderScreen('Opportunity: $id');
              },
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.resources,
          name: 'resources',
          builder: (context, state) => const ResourcesScreen(),
        ),
        GoRoute(
          path: AppRoutes.messages,
          name: 'messages',
          builder: (context, state) => const MessagesScreen(),
          routes: [
            GoRoute(
              path: ':conversationId',
              name: 'chat',
              builder: (context, state) {
                final id = state.pathParameters['conversationId']!;
                return ChatScreen(conversationId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.progress,
          name: 'progress',
          builder: (context, state) => const ProgressScreen(),
        ),

        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: AppRoutes.upgrade,
          name: 'upgrade',
          builder: (context, state) => const UpgradeScreen(),
        ),
      ],
    ),
  ];
}