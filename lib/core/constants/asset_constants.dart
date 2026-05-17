/// All asset paths in one place.
/// Never hardcode asset paths directly in widgets.
class AssetConstants {
  AssetConstants._();

  // ─── Animations (Lottie) ─────────────────────────────────────────────
  static const String aiThinkingAnimation =
      'assets/animations/ai_thinking.json';
  static const String successAnimation =
      'assets/animations/success.json';
  static const String loadingAnimation =
      'assets/animations/loading.json';
  static const String splashAnimation =
      'assets/animations/splash.json';
  static const String waveformAnimation =
      'assets/animations/waveform.json';

  // ─── Images ──────────────────────────────────────────────────────────
  static const String logo = 'assets/images/logos/unilink_logo.png';
  static const String onboarding1 =
      'assets/images/onboarding/onboarding_1.png';
  static const String onboarding2 =
      'assets/images/onboarding/onboarding_2.png';
  static const String onboarding3 =
      'assets/images/onboarding/onboarding_3.png';

  // ─── Placeholder avatar (used when no image is set) ──────────────────
  static const String defaultAvatar =
      'assets/images/avatars/default_avatar.png';
}