import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../main.dart';
import '../../domain/models/user_profile.dart';

/// Authentication Repository
/// Handles all authentication operations with Supabase
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository({SupabaseClient? client}) : _client = client ?? supabase;

  /// Send OTP to phone number
  /// Returns true if OTP sent successfully
  Future<void> sendOTP(String phoneNumber) async {
    try {
      await _client.auth.signInWithOtp(
        phone: phoneNumber,
        channel: OtpChannel.sms,
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('OTP gönderilemedi: $e');
    }
  }

  /// Verify OTP code
  /// Returns the authenticated user
  Future<User> verifyOTP({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      final response = await _client.auth.verifyOTP(
        type: OtpType.sms,
        phone: phoneNumber,
        token: otpCode,
      );

      if (response.user == null) {
        throw Exception('Doğrulama başarısız');
      }

      return response.user!;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Doğrulama başarısız: $e');
    }
  }

  /// Get user profile from database
  /// Returns null if profile doesn't exist
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Profil bilgisi alınamadı: $e');
    }
  }

  /// Create new user profile
  /// Used for first-time users
  Future<UserProfile> createUserProfile({
    required String userId,
    required String phone,
    String role = 'customer',
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      final data = {
        'id': userId,
        'phone': phone,
        'role': role,
        'created_at': now,
        'updated_at': now,
      };

      final response = await _client
          .from('user_profiles')
          .insert(data)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Profil oluşturulamadı: $e');
    }
  }

  /// Update user profile
  Future<UserProfile> updateUserProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
    String? deviceToken,
  }) async {
    try {
      final data = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) data['full_name'] = fullName;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;
      if (deviceToken != null) data['device_token'] = deviceToken;

      final response = await _client
          .from('user_profiles')
          .update(data)
          .eq('id', userId)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Profil güncellenemedi: $e');
    }
  }

  /// Update device token for push notifications
  Future<void> updateDeviceToken({
    required String userId,
    required String deviceToken,
  }) async {
    try {
      await _client
          .from('user_profiles')
          .update({
            'device_token': deviceToken,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      throw Exception('Cihaz token güncellenemedi: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Çıkış yapılamadı: $e');
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  /// Listen to auth state changes
  Stream<AuthState> authStateChanges() {
    return _client.auth.onAuthStateChange;
  }

  /// Handle auth exceptions with Turkish messages
  String _handleAuthException(AuthException e) {
    switch (e.message.toLowerCase()) {
      case 'invalid otp':
      case 'token expired':
        return 'Doğrulama kodu hatalı veya süresi dolmuş';
      case 'invalid phone number':
        return 'Geçersiz telefon numarası';
      case 'user not found':
        return 'Kullanıcı bulunamadı';
      case 'too many requests':
        return 'Çok fazla deneme yaptınız. Lütfen daha sonra tekrar deneyin';
      default:
        return e.message;
    }
  }
}
