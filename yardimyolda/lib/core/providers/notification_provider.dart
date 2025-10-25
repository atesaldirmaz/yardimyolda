import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

/// NotificationService provider
/// Singleton olarak NotificationService instance'ını sağlar
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Bildirim izin durumu state'i
enum NotificationPermissionState {
  unknown,
  requesting,
  granted,
  denied,
  notDetermined,
}

/// Bildirim izin durumu notifier'ı
class NotificationPermissionNotifier extends StateNotifier<NotificationPermissionState> {
  NotificationPermissionNotifier(this._notificationService)
      : super(NotificationPermissionState.unknown);

  final NotificationService _notificationService;

  /// Bildirim izni ister
  Future<bool> requestPermission() async {
    try {
      state = NotificationPermissionState.requesting;

      final settings = await _notificationService.requestPermission();

      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
        case AuthorizationStatus.provisional:
          state = NotificationPermissionState.granted;
          return true;
        case AuthorizationStatus.denied:
          state = NotificationPermissionState.denied;
          return false;
        case AuthorizationStatus.notDetermined:
          state = NotificationPermissionState.notDetermined;
          return false;
      }
    } catch (e) {
      debugPrint('Bildirim izni isteme hatası: $e');
      state = NotificationPermissionState.denied;
      return false;
    }
  }

  /// İzin durumunu kontrol eder
  Future<void> checkPermissionStatus() async {
    try {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();

      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
        case AuthorizationStatus.provisional:
          state = NotificationPermissionState.granted;
          break;
        case AuthorizationStatus.denied:
          state = NotificationPermissionState.denied;
          break;
        case AuthorizationStatus.notDetermined:
          state = NotificationPermissionState.notDetermined;
          break;
      }
    } catch (e) {
      debugPrint('İzin durumu kontrol hatası: $e');
      state = NotificationPermissionState.unknown;
    }
  }
}

/// Bildirim izin durumu provider'ı
final notificationPermissionProvider =
    StateNotifierProvider<NotificationPermissionNotifier, NotificationPermissionState>(
  (ref) {
    final notificationService = ref.watch(notificationServiceProvider);
    return NotificationPermissionNotifier(notificationService);
  },
);

/// FCM device token state'i
class FcmTokenState {
  final String? token;
  final bool isLoading;
  final String? error;

  FcmTokenState({
    this.token,
    this.isLoading = false,
    this.error,
  });

  FcmTokenState copyWith({
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return FcmTokenState(
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// FCM device token notifier'ı
class FcmTokenNotifier extends StateNotifier<FcmTokenState> {
  FcmTokenNotifier(this._notificationService) : super(FcmTokenState());

  final NotificationService _notificationService;

  /// FCM token'ı alır
  Future<String?> getToken() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final token = await _notificationService.getDeviceToken();

      state = state.copyWith(
        token: token,
        isLoading: false,
      );

      return token;
    } catch (e) {
      debugPrint('FCM token alma hatası: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Token alınırken hata oluştu',
      );
      return null;
    }
  }

  /// Token'ı veritabanına kaydeder
  Future<bool> saveToken(String userId, String token) async {
    try {
      final success = await _notificationService.saveTokenToDatabase(
        userId,
        token,
      );

      if (!success) {
        state = state.copyWith(error: 'Token kaydedilirken hata oluştu');
      }

      return success;
    } catch (e) {
      debugPrint('Token kaydetme hatası: $e');
      state = state.copyWith(error: 'Token kaydedilirken hata oluştu');
      return false;
    }
  }

  /// Token'ı yeniler
  void refreshToken() {
    getToken();
  }
}

/// FCM device token provider'ı
final fcmTokenProvider = StateNotifierProvider<FcmTokenNotifier, FcmTokenState>(
  (ref) {
    final notificationService = ref.watch(notificationServiceProvider);
    return FcmTokenNotifier(notificationService);
  },
);

/// Bildirim başlatma durumu
enum NotificationInitState {
  notInitialized,
  initializing,
  initialized,
  failed,
}

/// Bildirim başlatma notifier'ı
class NotificationInitNotifier extends StateNotifier<NotificationInitState> {
  NotificationInitNotifier(this._notificationService)
      : super(NotificationInitState.notInitialized);

  final NotificationService _notificationService;

  /// Bildirim servisini başlatır
  Future<bool> initialize() async {
    try {
      state = NotificationInitState.initializing;

      await _notificationService.initialize();

      state = NotificationInitState.initialized;
      return true;
    } catch (e) {
      debugPrint('Bildirim servisi başlatma hatası: $e');
      state = NotificationInitState.failed;
      return false;
    }
  }

  /// Başlatma durumunu sıfırlar
  void reset() {
    state = NotificationInitState.notInitialized;
  }
}

/// Bildirim başlatma durumu provider'ı
final notificationInitProvider =
    StateNotifierProvider<NotificationInitNotifier, NotificationInitState>(
  (ref) {
    final notificationService = ref.watch(notificationServiceProvider);
    return NotificationInitNotifier(notificationService);
  },
);

/// Helper provider: Bildirim gösterme
/// Bu provider notification service'in showNotification metodunu kullanır
final showNotificationProvider = Provider<Future<void> Function({
  required String title,
  required String body,
  String? payload,
})>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return ({
    required String title,
    required String body,
    String? payload,
  }) async {
    await notificationService.showNotification(
      title: title,
      body: body,
      payload: payload,
    );
  };
});

/// Helper provider: Servis durum bildirimi gösterme
final showServiceStatusNotificationProvider = Provider<Future<void> Function({
  required String serviceType,
  required String status,
  String? serviceRequestId,
})>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return ({
    required String serviceType,
    required String status,
    String? serviceRequestId,
  }) async {
    await notificationService.showServiceStatusNotification(
      serviceType: serviceType,
      status: status,
      serviceRequestId: serviceRequestId,
    );
  };
});
