import '../../models/user_model.dart';
import '../../core/enums/user_role.dart';
import '../../core/enums/education_level.dart';

/// Contract for all authentication operations.
/// Swap [MockAuthRepository] → [ApiAuthRepository] in the provider
/// when the real backend is ready. Zero UI changes required.
abstract class AuthRepository {
  /// Returns the currently authenticated user, or null if not signed in.
  Future<UserModel?> getCurrentUser();

  /// Sign in with email and password.
  /// Throws [AuthException] on failure.
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  /// Register a new account.
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  });

  /// Initiate Google OAuth flow.
  /// Returns the signed-in user on success.
  Future<UserModel> signInWithGoogle();

  /// Sign out the current user.
  Future<void> signOut();

  /// Send a password reset email.
  Future<void> forgotPassword({required String email});

  /// Reset password using the token received via email.
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  /// Update the user's education level (students only).
  Future<UserModel> updateEducationLevel({
    required String userId,
    required EducationLevel level,
  });

  /// Complete multi-step profile setup after registration.
  Future<UserModel> completeProfileSetup({
    required String userId,
    required Map<String, dynamic> profileData,
  });

  /// Check if the current session token is still valid.
  Future<bool> isSessionValid();

  /// Stream that emits auth state changes (signed in / signed out).
  /// Connect to Firebase Auth stream or REST polling when real.
  Stream<UserModel?> get authStateChanges;
}