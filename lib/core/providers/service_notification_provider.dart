import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/service_notification_listener.dart';

/// ServiceNotificationListener provider
/// Singleton olarak ServiceNotificationListener instance'ını sağlar
final serviceNotificationListenerProvider = Provider<ServiceNotificationListener>((ref) {
  return ServiceNotificationListener();
});

/// Service notification listener durumu
enum ServiceListenerState {
  idle,
  starting,
  listening,
  stopping,
  error,
}

/// Service notification listener state
class ServiceListenerStatus {
  final ServiceListenerState state;
  final String? userId;
  final String? error;

  ServiceListenerStatus({
    required this.state,
    this.userId,
    this.error,
  });

  ServiceListenerStatus copyWith({
    ServiceListenerState? state,
    String? userId,
    String? error,
  }) {
    return ServiceListenerStatus(
      state: state ?? this.state,
      userId: userId ?? this.userId,
      error: error ?? this.error,
    );
  }
}

/// Service notification listener notifier
class ServiceNotificationNotifier extends StateNotifier<ServiceListenerStatus> {
  ServiceNotificationNotifier(this._listener)
      : super(ServiceListenerStatus(state: ServiceListenerState.idle));

  final ServiceNotificationListener _listener;

  /// Listener'ı başlatır
  Future<void> startListening(String userId) async {
    try {
      state = ServiceListenerStatus(
        state: ServiceListenerState.starting,
        userId: userId,
      );

      await _listener.startListening(userId);

      state = ServiceListenerStatus(
        state: ServiceListenerState.listening,
        userId: userId,
      );

      debugPrint('✅ Service notification listener başlatıldı: $userId');
    } catch (e) {
      debugPrint('❌ Service notification listener başlatma hatası: $e');
      state = ServiceListenerStatus(
        state: ServiceListenerState.error,
        userId: userId,
        error: e.toString(),
      );
    }
  }

  /// Listener'ı durdurur
  Future<void> stopListening() async {
    try {
      state = state.copyWith(state: ServiceListenerState.stopping);

      await _listener.stopListening();

      state = ServiceListenerStatus(state: ServiceListenerState.idle);

      debugPrint('✅ Service notification listener durduruldu');
    } catch (e) {
      debugPrint('❌ Service notification listener durdurma hatası: $e');
      state = state.copyWith(
        state: ServiceListenerState.error,
        error: e.toString(),
      );
    }
  }

  /// Listener'ı yeniden başlatır
  Future<void> restartListening(String userId) async {
    await stopListening();
    await startListening(userId);
  }
}

/// Service notification listener state provider
final serviceNotificationProvider =
    StateNotifierProvider<ServiceNotificationNotifier, ServiceListenerStatus>(
  (ref) {
    final listener = ref.watch(serviceNotificationListenerProvider);
    return ServiceNotificationNotifier(listener);
  },
);

/// Auto-start service notification listener when user is authenticated
/// Bu provider kullanıcı authenticate olduğunda otomatik olarak listener'ı başlatır
final autoStartServiceListenerProvider = Provider<void>((ref) {
  // Auth state'i izle
  // Not: Bu import'u auth provider'dan eklemek gerekecek
  // final authState = ref.watch(authStateProvider);
  
  // Kullanıcı authenticate ise listener'ı başlat
  // if (authState.isAuthenticated && authState.user != null) {
  //   ref.read(serviceNotificationProvider.notifier)
  //       .startListening(authState.user!.id);
  // } else {
  //   // Kullanıcı logout olduysa listener'ı durdur
  //   ref.read(serviceNotificationProvider.notifier).stopListening();
  // }
  
  // Şimdilik manuel olarak çağrılacak
});
