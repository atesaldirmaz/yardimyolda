
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_profile.dart';

/// Authentication State
/// Represents the current authentication state of the user
class AuthState {
  final User? user;
  final UserProfile? profile;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.profile,
    this.isLoading = false,
    this.error,
  });

  /// Initial state
  const AuthState.initial()
      : user = null,
        profile = null,
        isLoading = true,
        error = null;

  /// Authenticated state
  const AuthState.authenticated({
    required this.user,
    required this.profile,
  })  : isLoading = false,
        error = null;

  /// Unauthenticated state
  const AuthState.unauthenticated()
      : user = null,
        profile = null,
        isLoading = false,
        error = null;

  /// Loading state
  const AuthState.loading()
      : user = null,
        profile = null,
        isLoading = true,
        error = null;

  /// Error state
  const AuthState.error(this.error)
      : user = null,
        profile = null,
        isLoading = false;

  /// Check if authenticated
  bool get isAuthenticated => user != null && profile != null;

  /// Check if new user (needs onboarding)
  bool get isNewUser => user != null && profile == null;

  /// Copy with
  AuthState copyWith({
    User? user,
    UserProfile? profile,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

