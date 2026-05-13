/// All named route paths in one place.
/// GoRouter uses these strings. Never hardcode paths in widgets.
class AppRoutes {
  AppRoutes._();

  // ─── Public / No Auth Required ────────────────────────────────────────
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String roleSelection = '/role-selection';
  static const String explorePublic = '/explore';

  // ─── Auth ─────────────────────────────────────────────────────────────
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String profileSetup = '/profile-setup';

  // ─── Main App Shell (requires auth) ──────────────────────────────────
  static const String shell = '/app';
  static const String dashboard = '/app/dashboard';
  static const String careers = '/app/careers';
  static const String careerDetail = '/app/careers/:careerId';
  static const String mentors = '/app/mentors';
  static const String mentorDetail = '/app/mentors/:mentorId';
  static const String bookSession = '/app/mentors/:mentorId/book';
  static const String community = '/app/community';
  static const String aiAssistant = '/app/ai';
  static const String aiVoice = '/app/ai/voice';

  // ─── Drawer Pages (requires auth) ─────────────────────────────────────
  static const String opportunities = '/app/opportunities';
  static const String opportunityDetail = '/app/opportunities/:opportunityId';
  static const String resources = '/app/resources';
  static const String messages = '/app/messages';
  static const String chat = '/app/messages/:conversationId';
  static const String progress = '/app/progress';
  static const String profile = '/app/profile';
  static const String settings = '/app/settings';

  // ─── Premium ──────────────────────────────────────────────────────────
  static const String upgrade = '/app/upgrade';

  // ─── Helpers ──────────────────────────────────────────────────────────
  /// Build a path with a dynamic segment filled in.
  static String careerDetailPath(String careerId) =>
      '/app/careers/$careerId';

  static String mentorDetailPath(String mentorId) =>
      '/app/mentors/$mentorId';

  static String bookSessionPath(String mentorId) =>
      '/app/mentors/$mentorId/book';

  static String opportunityDetailPath(String opportunityId) =>
      '/app/opportunities/$opportunityId';

  static String chatPath(String conversationId) =>
      '/app/messages/$conversationId';
}