import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/services/notification_service.dart';
import '../../../core/services/service_notification_listener.dart';
import '../../../main.dart';
import '../data/repositories/auth_repository.dart';
import '../domain/models/auth_state.dart';
import '../domain/models/user_profile.dart';

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Auth State Notifier
/// Manages authentication state and operations
class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final NotificationService _notificationService;
  final ServiceNotificationListener _serviceNotificationListener;
  StreamSubscription<supabase.AuthState>? _authSubscription;

  AuthStateNotifier(
    this._repository,
    this._notificationService,
    this._serviceNotificationListener,
  ) : super(const AuthState.initial()) {
    _initialize();
  }

  /// Initialize auth state and listen to changes
  Future<void> _initialize() async {
    try {
      // Check current session
      final user = _repository.getCurrentUser();
      
      if (user != null) {
        // User is logged in, fetch profile
        final profile = await _repository.getUserProfile(user.id);
        
        if (profile != null) {
          state = AuthState.authenticated(user: user, profile: profile);
        } else {
          // User exists but no profile (new user)
          state = AuthState(user: user, profile: null, isLoading: false);
        }
      } else {
        // No user logged in
        state = const AuthState.unauthenticated();
      }

      // Listen to auth state changes
      _authSubscription = _repository.authStateChanges().listen(
        (authState) => _onAuthStateChange(authState),
        onError: (error) {
          state = AuthState.error(error.toString());
        },
      );
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Handle auth state changes from Supabase
  Future<void> _onAuthStateChange(supabase.AuthState authState) async {
    final user = authState.session?.user;

    if (user == null) {
      // User logged out - stop service notification listener
      await _serviceNotificationListener.stopListening();
      state = const AuthState.unauthenticated();
      return;
    }

    try {
      // Fetch user profile
      final profile = await _repository.getUserProfile(user.id);
      
      if (profile != null) {
        state = AuthState.authenticated(user: user, profile: profile);
        
        // Start service notification listener for authenticated user
        _startServiceNotificationListener(user.id);
      } else {
        // New user without profile
        state = AuthState(user: user, profile: null, isLoading: false);
      }
    } catch (e) {
      state = AuthState.error('Profil yüklenemedi: $e');
    }
  }

  /// Send OTP to phone number
  Future<void> sendOTP(String phoneNumber) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repository.sendOTP(phoneNumber);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Verify OTP code
  Future<void> verifyOTP({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Verify OTP
      final user = await _repository.verifyOTP(
        phoneNumber: phoneNumber,
        otpCode: otpCode,
      );

      // Check if user profile exists
      final profile = await _repository.getUserProfile(user.id);

      if (profile == null) {
        // New user - create profile with customer role
        final newProfile = await _repository.createUserProfile(
          userId: user.id,
          phone: phoneNumber,
          role: 'customer',
        );
        
        state = AuthState.authenticated(user: user, profile: newProfile);
      } else {
        // Existing user
        state = AuthState.authenticated(user: user, profile: profile);
      }

      // Request notification permissions and save FCM token
      // This runs in the background and doesn't block the auth flow
      _requestNotificationPermissionsAndSaveToken(user.id);
      
      // Start service notification listener
      _startServiceNotificationListener(user.id);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Start service notification listener for the user
  void _startServiceNotificationListener(String userId) {
    try {
      debugPrint('🎧 Servis bildirimleri dinleniyor: $userId');
      _serviceNotificationListener.startListening(userId);
    } catch (e) {
      // Don't throw error - listener failure shouldn't block auth flow
      debugPrint('⚠️ Servis bildirim listener başlatma hatası: $e');
    }
  }

  /// Request notification permissions and save FCM token
  /// This is called after successful authentication
  Future<void> _requestNotificationPermissionsAndSaveToken(String userId) async {
    try {
      debugPrint('🔔 Bildirim izinleri isteniyor...');
      
      // Request notification permissions
      final settings = await _notificationService.requestPermission();
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('✅ Bildirim izni verildi');
        
        // Get FCM token
        final token = await _notificationService.getDeviceToken();
        
        if (token != null) {
          debugPrint('✅ FCM token alındı: ${token.substring(0, 20)}...');
          
          // Save token to database
          await _repository.updateDeviceToken(
            userId: userId,
            deviceToken: token,
          );
          
          debugPrint('✅ FCM token veritabanına kaydedildi');
        } else {
          debugPrint('⚠️ FCM token alınamadı');
        }
      } else {
        debugPrint('⚠️ Bildirim izni verilmedi');
      }
    } catch (e) {
      // Don't throw error - notification failure shouldn't block auth flow
      debugPrint('⚠️ Bildirim izni/token kaydetme hatası: $e');
    }
  }

  /// Create user profile (for new users after onboarding)
  Future<void> createProfile({
    required String fullName,
    String role = 'customer',
  }) async {
    try {
      if (state.user == null) {
        throw Exception('Kullanıcı bulunamadı');
      }

      state = state.copyWith(isLoading: true, error: null);

      final profile = await _repository.createUserProfile(
        userId: state.user!.id,
        phone: state.user!.phone ?? '',
        role: role,
      );

      // Update profile with full name if provided
      final updatedProfile = await _repository.updateUserProfile(
        userId: state.user!.id,
        fullName: fullName,
      );

      state = AuthState.authenticated(
        user: state.user!,
        profile: updatedProfile,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      if (state.user == null) {
        throw Exception('Kullanıcı bulunamadı');
      }

      state = state.copyWith(isLoading: true, error: null);

      final updatedProfile = await _repository.updateUserProfile(
        userId: state.user!.id,
        fullName: fullName,
        avatarUrl: avatarUrl,
      );

      state = AuthState.authenticated(
        user: state.user!,
        profile: updatedProfile,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Stop service notification listener
      await _serviceNotificationListener.stopListening();
      
      await _repository.signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Auth State Provider
/// Main provider for authentication state
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(
    ref.watch(authRepositoryProvider),
    NotificationService(),
    ServiceNotificationListener(),
  );
});

/// Current User Provider
/// Provides easy access to current user
final currentUserProvider = Provider<supabase.User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.user;
});

/// Current User Profile Provider
/// Provides easy access to current user profile
final currentUserProfileProvider = Provider<UserProfile?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.profile;
});

/// Is Authenticated Provider
/// Quick check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isAuthenticated;
});
