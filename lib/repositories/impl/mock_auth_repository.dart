import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../abstracts/auth_repository.dart';
import '../../models/user_model.dart';
import '../../core/enums/user_role.dart';
import '../../core/enums/education_level.dart';
import '../../core/constants/app_constants.dart';
import '../../mock/mock_users.dart';

class MockAuthRepository implements AuthRepository {
  // Simulates currently authenticated user in memory
  UserModel? _currentUser;

  // StreamController simulates auth state changes
  // Replace with FirebaseAuth.instance.authStateChanges() in production
  final _authStateController = StreamController<UserModel?>.broadcast();

  MockAuthRepository() {
    // Default to student for development
    _currentUser = MockUsers.currentStudent;
    _authStateController.add(_currentUser);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    await _simulateDelay(300);
    return _currentUser;
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _simulateDelay(1000);
    // Mock: any email/password succeeds
    _currentUser = MockUsers.currentStudent;
    _authStateController.add(_currentUser);
    await _persistSession(_currentUser!);
    return _currentUser!;
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    await _simulateDelay(1200);
    _currentUser = MockUsers.currentStudent.copyWith(
      email: email,
      fullName: fullName,
      role: role,
      isProfileComplete: false,
      profileCompletionPercent: 20,
    );
    _authStateController.add(_currentUser);
    await _persistSession(_currentUser!);
    return _currentUser!;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    await _simulateDelay(1500);
    _currentUser = MockUsers.currentStudent;
    _authStateController.add(_currentUser);
    await _persistSession(_currentUser!);
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    await _simulateDelay(500);
    _currentUser = null;
    _authStateController.add(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyAuthToken);
    await prefs.remove(AppConstants.keyUserId);
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _simulateDelay(800);
    // Mock: always succeeds
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _simulateDelay(800);
    // Mock: always succeeds
  }

  @override
  Future<UserModel> updateEducationLevel({
    required String userId,
    required EducationLevel level,
  }) async {
    await _simulateDelay(400);
    _currentUser = _currentUser?.copyWith(educationLevel: level);
    return _currentUser!;
  }

  @override
  Future<UserModel> completeProfileSetup({
    required String userId,
    required Map<String, dynamic> profileData,
  }) async {
    await _simulateDelay(800);
    _currentUser = _currentUser?.copyWith(
      bio: profileData['bio'] as String?,
      location: profileData['location'] as String?,
      skills: profileData['skills'] != null
          ? List<String>.from(profileData['skills'] as List)
          : null,
      interests: profileData['interests'] != null
          ? List<String>.from(profileData['interests'] as List)
          : null,
      schoolOrUniversity: profileData['school_or_university'] as String?,
      isProfileComplete: true,
      profileCompletionPercent: 90,
    );
    return _currentUser!;
  }

  @override
  Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(AppConstants.keyAuthToken);
  }

  @override
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  // ─── Helpers ──────────────────────────────────────────────────────────────
  Future<void> _persistSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyAuthToken, 'mock_token_${user.id}');
    await prefs.setString(AppConstants.keyUserId, user.id);
    await prefs.setString(AppConstants.keyUserRole, user.role.name);
  }

  Future<void> _simulateDelay(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  void dispose() {
    _authStateController.close();
  }
}