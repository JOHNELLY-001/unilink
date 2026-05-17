import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ─── Providers ───────────────────────────────────────────────────────────
import '../providers/auth_provider.dart';

// ─── Routes ──────────────────────────────────────────────────────────────
import 'app_routes.dart';
import 'route_guards.dart';

// ─── Shell ───────────────────────────────────────────────────────────────
import '../features/shell/app_shell.dart';

// ─── Splash / Onboarding ─────────────────────────────────────────────────
import '../features/splash/splash_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/onboarding/screens/role_selection_screen.dart';

// ─── Auth ─────────────────────────────────────────────────────────────────
import '../features/auth/screens/sign_in_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/profile_setup_screen.dart';

// ─── Public Explore ───────────────────────────────────────────────────────
import '../features/explore/screens/explore_home_screen.dart';

// ─── Dashboard ───────────────────────────────────────────────────────────
import '../features/dashboard/screens/student_dashboard.dart';
import '../features/dashboard/screens/mentor_dashboard.dart';

// ─── Careers ─────────────────────────────────────────────────────────────
import '../features/careers/screens/careers_screen.dart';
import '../features/careers/screens/career_detail_screen.dart';

// ─── Mentors ─────────────────────────────────────────────────────────────
import '../features/mentors/screens/mentors_screen.dart';
import '../features/mentors/screens/mentor_detail_screen.dart';
import '../features/mentors/screens/book_session_screen.dart';

// ─── Community ───────────────────────────────────────────────────────────
import '../features/community/screens/community_screen.dart';

// ─── Opportunities ────────────────────────────────────────────────────────
import '../features/opportunities/screens/opportunities_screen.dart';
import '../features/opportunities/screens/opportunity_detail_screen.dart';

// ─── Resources ───────────────────────────────────────────────────────────
import '../features/resources/screens/resources_screen.dart';

// ─── Messages ────────────────────────────────────────────────────────────
import '../features/messages/screens/messages_screen.dart';
import '../features/messages/screens/chat_screen.dart';

// ─── Progress ────────────────────────────────────────────────────────────
import '../features/progress/screens/progress_screen.dart';

// ─── Profile ─────────────────────────────────────────────────────────────
import '../features/profile/screens/profile_screen.dart';

// ─── Settings ────────────────────────────────────────────────────────────
import '../features/settings/screens/settings_screen.dart';

// ─── AI Assistant ────────────────────────────────────────────────────────
import '../features/ai_assistant/screens/ai_chat_screen.dart';
import '../features/ai_assistant/screens/ai_voice_screen.dart';

// ─── Premium ─────────────────────────────────────────────────────────────
import '../features/premium/screens/upgrade_screen.dart';

// ─── Core ────────────────────────────────────────────────────────────────
import '../core/enums/user_role.dart';

// ─────────────────────────────────────────────────────────────────────────
// Router Provider
// ─────────────────────────────────────────────────────────────────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      return evaluateRedirect(
        state: state,
        authState: authState,
      );
    },
    routes: _buildRoutes(ref),
  );
});

// ─────────────────────────────────────────────────────────────────────────
// Route Definitions
// ─────────────────────────────────────────────────────────────────────────

List<RouteBase> _buildRoutes(Ref ref) {
  return [
    // ═══════════════════════════════════════════════════
    // PUBLIC ROUTES (no auth required)
    // ═══════════════════════════════════════════════════

    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    GoRoute(
      path: AppRoutes.roleSelection,
      name: 'roleSelection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),

    GoRoute(
      path: AppRoutes.explorePublic,
      name: 'explorePublic',
      builder: (context, state) => const ExploreHomeScreen(),
    ),

    // ═══════════════════════════════════════════════════
    // AUTH ROUTES
    // ═══════════════════════════════════════════════════

    GoRoute(
      path: AppRoutes.signIn,
      name: 'signIn',
      pageBuilder: (context, state) => _fadeTransition(
        state: state,
        child: const SignInScreen(),
      ),
    ),

    GoRoute(
      path: AppRoutes.signUp,
      name: 'signUp',
      pageBuilder: (context, state) => _fadeTransition(
        state: state,
        child: SignUpScreen(
          preselectedRole: state.extra as String?,
        ),
      ),
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

    // ═══════════════════════════════════════════════════
    // MAIN APP SHELL (requires auth)
    // ═══════════════════════════════════════════════════

    ShellRoute(
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        // ─── Dashboard ───────────────────────────────
        GoRoute(
          path: AppRoutes.dashboard,
          name: 'dashboard',
          builder: (context, state) {
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

        // ─── Careers ─────────────────────────────────
        GoRoute(
          path: AppRoutes.careers,
          name: 'careers',
          builder: (context, state) => const CareersScreen(),
          routes: [
            GoRoute(
              path: ':careerId',
              name: 'careerDetail',
              builder: (context, state) {
                final careerId =
                state.pathParameters['careerId']!;
                return CareerDetailScreen(careerId: careerId);
              },
            ),
          ],
        ),

        // ─── Mentors ─────────────────────────────────
        GoRoute(
          path: AppRoutes.mentors,
          name: 'mentors',
          builder: (context, state) => const MentorsScreen(),
          routes: [
            GoRoute(
              path: ':mentorId',
              name: 'mentorDetail',
              builder: (context, state) {
                final mentorId =
                state.pathParameters['mentorId']!;
                return MentorDetailScreen(mentorId: mentorId);
              },
              routes: [
                GoRoute(
                  path: 'book',
                  name: 'bookSession',
                  builder: (context, state) {
                    final mentorId =
                    state.pathParameters['mentorId']!;
                    return BookSessionScreen(
                        mentorId: mentorId);
                  },
                ),
              ],
            ),
          ],
        ),

        // ─── Community ───────────────────────────────
        GoRoute(
          path: AppRoutes.community,
          name: 'community',
          builder: (context, state) => const CommunityScreen(),
        ),

        // ─── AI Assistant ────────────────────────────
        GoRoute(
          path: AppRoutes.aiAssistant,
          name: 'aiAssistant',
          builder: (context, state) => const AiChatScreen(),
          routes: [
            GoRoute(
              path: 'voice',
              name: 'aiVoice',
              builder: (context, state) =>
              const AiVoiceScreen(),
            ),
          ],
        ),

        // ─── Opportunities ───────────────────────────
        GoRoute(
          path: AppRoutes.opportunities,
          name: 'opportunities',
          builder: (context, state) =>
          const OpportunitiesScreen(),
          routes: [
            GoRoute(
              path: ':opportunityId',
              name: 'opportunityDetail',
              builder: (context, state) {
                final id =
                state.pathParameters['opportunityId']!;
                return OpportunityDetailScreen(
                    opportunityId: id);
              },
            ),
          ],
        ),

        // ─── Resources ───────────────────────────────
        GoRoute(
          path: AppRoutes.resources,
          name: 'resources',
          builder: (context, state) =>
          const ResourcesScreen(),
        ),

        // ─── Messages ────────────────────────────────
        GoRoute(
          path: AppRoutes.messages,
          name: 'messages',
          builder: (context, state) =>
          const MessagesScreen(),
          routes: [
            GoRoute(
              path: ':conversationId',
              name: 'chat',
              builder: (context, state) {
                final id =
                state.pathParameters['conversationId']!;
                return ChatScreen(conversationId: id);
              },
            ),
          ],
        ),

        // ─── Progress ────────────────────────────────
        GoRoute(
          path: AppRoutes.progress,
          name: 'progress',
          builder: (context, state) =>
          const ProgressScreen(),
        ),

        // ─── Profile ─────────────────────────────────
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),

        // ─── Settings ────────────────────────────────
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          builder: (context, state) =>
          const SettingsScreen(),
        ),

        // ─── Upgrade ─────────────────────────────────
        GoRoute(
          path: AppRoutes.upgrade,
          name: 'upgrade',
          builder: (context, state) =>
          const UpgradeScreen(),
        ),
      ],
    ),
  ];
}

// ─── Custom page transition ───────────────────────────────────────────────

CustomTransitionPage<void> _fadeTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, _, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: child,
      );
    },
  );
}