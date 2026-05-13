class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'UniLink';
  static const String appTagline = 'Your Future, Guided by Intelligence';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int defaultPageSize = 20;
  static const int mentorsPageSize = 12;
  static const int opportunitiesPageSize = 15;

  // Animation durations (milliseconds)
  static const int splashDuration = 2500;
  static const int pageTransitionDuration = 300;
  static const int cardAnimationDuration = 400;
  static const int shimmerDuration = 1200;
  static const int aiTypingDuration = 1500;

  // Cache durations (minutes)
  static const int shortCacheDuration = 5;
  static const int mediumCacheDuration = 30;
  static const int longCacheDuration = 1440; // 24 hrs

  // Premium plan IDs
  static const String freePlanId = 'free';
  static const String proPlanId = 'pro';
  static const String premiumPlanId = 'premium';

  // SharedPreferences keys
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyAuthToken = 'auth_token';
  static const String keyUserRole = 'user_role';
  static const String keyUserId = 'user_id';
  static const String keyThemeMode = 'theme_mode';
  static const String keySelectedPlan = 'selected_plan';

  // Mentor approval status
  static const String mentorStatusPending = 'pending';
  static const String mentorStatusApproved = 'approved';
  static const String mentorStatusRejected = 'rejected';

  // Max values
  static const int maxSkillsDisplay = 5;
  static const int maxMentorSessions = 3; // free tier
  static const int aiMessagesFreeTier = 10;
  static const int aiMessagesProTier = 100;

  // Feature flags (set false to lock behind premium)
  static const bool featureAiChatFree = true;
  static const bool featureMentorBookingFree = false;
  static const bool featureAdvancedFiltersFree = false;
  static const bool featureCareerRoadmapFree = true;
  static const bool featureCommunityFree = true;
}