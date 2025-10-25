import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import 'notification_service.dart';

/// Servis taleplerinin durum değişikliklerini dinleyen ve bildirim gösteren servis
/// 
/// Bu servis Supabase Realtime kullanarak service_requests tablosundaki
/// status değişikliklerini izler ve kullanıcıya bildirim gösterir.
class ServiceNotificationListener {
  static final ServiceNotificationListener _instance =
      ServiceNotificationListener._internal();
  factory ServiceNotificationListener() => _instance;
  ServiceNotificationListener._internal();

  final NotificationService _notificationService = NotificationService();
  RealtimeChannel? _channel;
  bool _isListening = false;
  String? _currentUserId;

  /// Listener'ın aktif olup olmadığını döndürür
  bool get isListening => _isListening;

  /// Belirtilen kullanıcı için service_requests tablosunu dinlemeye başlar
  /// 
  /// [userId] - İzlenecek kullanıcının ID'si
  Future<void> startListening(String userId) async {
    if (_isListening && _currentUserId == userId) {
      debugPrint('ServiceNotificationListener zaten dinliyor: $userId');
      return;
    }

    // Önceki listener'ı durdur
    await stopListening();

    try {
      _currentUserId = userId;

      debugPrint('🎧 ServiceNotificationListener başlatılıyor: $userId');

      // Realtime channel oluştur
      _channel = supabase.channel('service_requests_$userId');

      // service_requests tablosundaki değişiklikleri dinle
      _channel!
          .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'service_requests',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'customer_id',
          value: userId,
        ),
        callback: (payload) => _handleServiceRequestUpdate(payload),
      )
          .subscribe((status, [error]) {
        if (status == RealtimeSubscribeStatus.subscribed) {
          _isListening = true;
          debugPrint('✅ ServiceNotificationListener başarıyla başlatıldı');
        } else if (status == RealtimeSubscribeStatus.closed) {
          _isListening = false;
          debugPrint('⚠️ ServiceNotificationListener kapatıldı');
        } else if (error != null) {
          _isListening = false;
          debugPrint('❌ ServiceNotificationListener hatası: $error');
        }
      });
    } catch (e) {
      debugPrint('❌ ServiceNotificationListener başlatma hatası: $e');
      _isListening = false;
      rethrow;
    }
  }

  /// Service request güncelleme payload'ını işler ve bildirim gösterir
  void _handleServiceRequestUpdate(PostgresChangePayload payload) {
    try {
      debugPrint('📬 Service request güncellendi: ${payload.newRecord}');

      final oldRecord = payload.oldRecord;
      final newRecord = payload.newRecord;

      // Status değişikliği var mı kontrol et
      final oldStatus = oldRecord['status'] as String?;
      final newStatus = newRecord['status'] as String?;

      if (oldStatus == null || newStatus == null || oldStatus == newStatus) {
        debugPrint('⚠️ Status değişikliği yok veya null');
        return;
      }

      debugPrint('📊 Status değişti: $oldStatus -> $newStatus');

      // Service type bilgisini al
      final serviceType = _getServiceTypeName(newRecord['service_type'] as String?);
      final serviceRequestId = newRecord['id'] as String?;

      // Bildirim göster
      _notificationService.showServiceStatusNotification(
        serviceType: serviceType,
        status: newStatus,
        serviceRequestId: serviceRequestId,
      );

      debugPrint('🔔 Bildirim gönderildi: $serviceType - $newStatus');
    } catch (e) {
      debugPrint('❌ Service request update işleme hatası: $e');
    }
  }

  /// Service type kodunu Türkçe isime çevirir
  String _getServiceTypeName(String? serviceType) {
    if (serviceType == null) return 'Servis';

    switch (serviceType.toLowerCase()) {
      case 'tow':
      case 'towing':
      case 'cekici':
        return 'Çekici';
      case 'tire_change':
      case 'tire':
      case 'lastik':
        return 'Lastik Değişimi';
      case 'jump_start':
      case 'jumpstart':
      case 'akuleme':
        return 'Akü Lemesi';
      case 'fuel_delivery':
      case 'fuel':
      case 'yakit':
        return 'Yakıt İkmali';
      case 'locksmith':
      case 'kilitle':
        return 'Anahtar Kilitleme';
      case 'winch':
      case 'vinc':
        return 'Vinç';
      default:
        return serviceType;
    }
  }

  /// Listener'ı durdurur
  Future<void> stopListening() async {
    if (!_isListening) {
      return;
    }

    try {
      debugPrint('🛑 ServiceNotificationListener durduruluyor...');

      if (_channel != null) {
        await supabase.removeChannel(_channel!);
        _channel = null;
      }

      _isListening = false;
      _currentUserId = null;

      debugPrint('✅ ServiceNotificationListener durduruldu');
    } catch (e) {
      debugPrint('❌ ServiceNotificationListener durdurma hatası: $e');
    }
  }

  /// Listener'ı yeniden başlatır
  Future<void> restart(String userId) async {
    await stopListening();
    await startListening(userId);
  }

  /// Servisi temizler
  void dispose() {
    stopListening();
  }
}
