/// All API endpoint constants.
/// Replace [baseUrl] and paths when connecting real backend.
/// Nothing in the UI layer touches these directly —
/// only repository implementations do.
class ApiConstants {
  ApiConstants._();

  // ─── Base URLs ───────────────────────────────────────────────────────────
  // TODO: Replace with real backend URL before production
  static const String baseUrl = 'https://api.unilink.co.tz/v1';
  static const String aiServiceUrl = 'https://ai.unilink.co.tz/v1';

  // ─── Auth ────────────────────────────────────────────────────────────────
  static const String signIn = '/auth/signin';
  static const String signUp = '/auth/signup';
  static const String signOut = '/auth/signout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String googleSignIn = '/auth/google';
  static const String verifyEmail = '/auth/verify-email';

  // ─── Users ───────────────────────────────────────────────────────────────
  static const String userProfile = '/users/me';
  static const String updateProfile = '/users/me/update';
  static const String uploadAvatar = '/users/me/avatar';
  static const String updateEducationLevel = '/users/me/education';

  // ─── Mentors ─────────────────────────────────────────────────────────────
  static const String mentors = '/mentors';
  static const String mentorById = '/mentors/:id';
  static const String mentorAvailability = '/mentors/:id/availability';
  static const String bookSession = '/mentors/:id/book';
  static const String mentorReviews = '/mentors/:id/reviews';
  static const String applyAsMentor = '/mentors/apply';

  // ─── Careers ─────────────────────────────────────────────────────────────
  static const String careers = '/careers';
  static const String careerById = '/careers/:id';
  static const String savedCareers = '/careers/saved';
  static const String saveCareer = '/careers/:id/save';

  // ─── Opportunities ───────────────────────────────────────────────────────
  static const String opportunities = '/opportunities';
  static const String opportunityById = '/opportunities/:id';
  static const String applyOpportunity = '/opportunities/:id/apply';
  static const String savedOpportunities = '/opportunities/saved';
  static const String bookmarkOpportunity = '/opportunities/:id/bookmark';

  // ─── Community ───────────────────────────────────────────────────────────
  static const String posts = '/community/posts';
  static const String postById = '/community/posts/:id';
  static const String createPost = '/community/posts/create';
  static const String reactToPost = '/community/posts/:id/react';
  static const String commentOnPost = '/community/posts/:id/comments';
  static const String events = '/community/events';
  static const String polls = '/community/polls';
  static const String voteOnPoll = '/community/polls/:id/vote';

  // ─── Resources ───────────────────────────────────────────────────────────
  static const String resources = '/resources';
  static const String resourceById = '/resources/:id';
  static const String savedResources = '/resources/saved';

  // ─── Messages ────────────────────────────────────────────────────────────
  static const String conversations = '/messages/conversations';
  static const String conversationById = '/messages/conversations/:id';
  static const String sendMessage = '/messages/conversations/:id/send';
  static const String markAsRead = '/messages/conversations/:id/read';

  // ─── AI Service ──────────────────────────────────────────────────────────
  static const String aiChat = '/ai/chat';
  static const String aiSuggestions = '/ai/suggestions';
  static const String aiCareerGuide = '/ai/career-guide';
  static const String aiVoice = '/ai/voice';
  static const String aiHistory = '/ai/history';

  // ─── Progress ────────────────────────────────────────────────────────────
  static const String userProgress = '/progress';
  static const String achievements = '/progress/achievements';
  static const String goals = '/progress/goals';
  static const String updateGoal = '/progress/goals/:id';
  static const String streak = '/progress/streak';

  // ─── Premium / Payments ──────────────────────────────────────────────────
  static const String plans = '/premium/plans';
  static const String subscribe = '/premium/subscribe';
  static const String cancelSubscription = '/premium/cancel';
  static const String paymentHistory = '/premium/history';

  // ─── Universities ────────────────────────────────────────────────────────
  static const String universities = '/universities';
  static const String universityById = '/universities/:id';

  // ─── Helper ──────────────────────────────────────────────────────────────
  /// Replaces `:id` placeholder in endpoint strings.
  /// Usage: ApiConstants.resolve(ApiConstants.mentorById, id: '123')
  static String resolve(String endpoint, {required String id}) {
    return endpoint.replaceFirst(':id', id);
  }
}