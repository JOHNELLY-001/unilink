import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import 'app_routes.dart';

/// Evaluates auth state and returns a redirect path if needed.
/// Called by GoRouter's [redirect] parameter on every navigation event.
///
/// Returns:
/// - null        → allow navigation
/// - a path str  → redirect to that path instead
String? evaluateRedirect({
  required GoRouterState state,
  required AuthState authState,
}) {
  // Still initializing — don't redirect yet
  if (authState.isLoading) return null;

  final isOnAuthRoute = _isAuthRoute(state.matchedLocation);
  final isOnPublicRoute = _isPublicRoute(state.matchedLocation);
  final isAuthenticated = authState.isAuthenticated;

  // Public and auth routes are always accessible
  if (isOnPublicRoute || isOnAuthRoute) {
    // Redirect authenticated users away from auth screens
    if (isAuthenticated && isOnAuthRoute) {
      return AppRoutes.dashboard;
    }
    return null;
  }

  // Protected routes require authentication
  if (!isAuthenticated) {
    return AppRoutes.signIn;
  }

  return null;
}

bool _isAuthRoute(String location) {
  return location.startsWith('/sign-in') ||
      location.startsWith('/sign-up') ||
      location.startsWith('/forgot-password') ||
      location.startsWith('/profile-setup') ||
      location.startsWith('/onboarding') ||
      location.startsWith('/role-selection') ||
      location == '/';
}

bool _isPublicRoute(String location) {
  return location.startsWith('/explore');
}