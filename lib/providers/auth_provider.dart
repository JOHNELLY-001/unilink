import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../core/enums/user_role.dart';
import '../core/enums/education_level.dart';
import 'repository_providers.dart';

// ─── Auth State ───────────────────────────────────────────────────────────

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null && user!.role != UserRole.guest;
  bool get isGuest => user == null || user!.role == UserRole.guest;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
  }) =>
      AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

// ─── Auth Notifier ────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    final repo = _ref.read(authRepositoryProvider);
    final user = await repo.getCurrentUser();
    state = AuthState(user: user);
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = _ref.read(authRepositoryProvider);
      final user = await repo.signInWithEmail(
          email: email, password: password);
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Sign in failed. Please try again.');
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = _ref.read(authRepositoryProvider);
      final user = await repo.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Registration failed. Please try again.');
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = _ref.read(authRepositoryProvider);
      final user = await repo.signInWithGoogle();
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Google sign in failed.');
      return false;
    }
  }

  Future<void> signOut() async {
    final repo = _ref.read(authRepositoryProvider);
    await repo.signOut();
    state = const AuthState();
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.forgotPassword(email: email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to send reset email.');
      return false;
    }
  }

  Future<bool> updateEducationLevel(EducationLevel level) async {
    if (state.user == null) return false;
    try {
      final repo = _ref.read(authRepositoryProvider);
      final updated = await repo.updateEducationLevel(
        userId: state.user!.id,
        level: level,
      );
      state = state.copyWith(user: updated);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> completeProfileSetup(Map<String, dynamic> data) async {
    if (state.user == null) return false;
    state = state.copyWith(isLoading: true);
    try {
      final repo = _ref.read(authRepositoryProvider);
      final updated = await repo.completeProfileSetup(
        userId: state.user!.id,
        profileData: data,
      );
      state = AuthState(user: updated);
      return true;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Profile setup failed.');
      return false;
    }
  }

  void clearError() => state = state.copyWith(error: null);
}

// ─── Providers ────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
      (ref) => AuthNotifier(ref),
);

/// Convenience providers derived from authProvider
final currentUserProvider = Provider<UserModel?>(
      (ref) => ref.watch(authProvider).user,
);

final isAuthenticatedProvider = Provider<bool>(
      (ref) => ref.watch(authProvider).isAuthenticated,
);

final userRoleProvider = Provider<UserRole>(
      (ref) => ref.watch(authProvider).user?.role ?? UserRole.guest,
);