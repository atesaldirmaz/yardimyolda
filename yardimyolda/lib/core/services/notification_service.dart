import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Top-level function to handle background messages
/// Must be a top-level function (not in a class)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message alındı: ${message.messageId}');
  debugPrint('Background message data: ${message.data}');
}

/// Firebase Cloud Messaging ve Local Notifications servisini yöneten sınıf
/// 
/// Bu servis şu işlevleri yerine getirir:
/// - Firebase Cloud Messaging başlatma
/// - Local notifications başlatma
/// - Bildirim izinlerini yönetme
/// - FCM device token alma ve kaydetme
/// - Foreground notifications gösterme
/// - Background/terminated durumlarında gelen bildirimleri işleme
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  String? _fcmToken;

  /// FCM device token'ı döndürür
  String? get fcmToken => _fcmToken;

  /// Servisi başlatır
  /// 
  /// Firebase ve local notifications'ı yapılandırır
  /// Background message handler'ı ayarlar
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('NotificationService zaten başlatılmış');
      return;
    }

    try {
      // Local notifications başlatma
      await _initializeLocalNotifications();

      // Background message handler'ı ayarla
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Foreground messages dinle
      _setupForegroundMessageHandler();

      // Message opened app dinle
      _setupMessageOpenedAppHandler();

      _isInitialized = true;
      debugPrint('NotificationService başarıyla başlatıldı');
    } catch (e) {
      debugPrint('NotificationService başlatma hatası: $e');
      // Hata durumunda bile devam et - kullanıcıya hata gösterilecek
      rethrow;
    }
  }

  /// Local notifications plugin'ini başlatır
  Future<void> _initializeLocalNotifications() async {
    // Android ayarları
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS ayarları
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // Başlatma ayarları
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Local notifications başlat
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Android notification channel oluştur
    if (Platform.isAndroid) {
      await _createAndroidNotificationChannel();
    }
  }

  /// Android için notification channel oluşturur
  Future<void> _createAndroidNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'yardimyolda_channel', // id
      'Yardım Yolda Bildirimleri', // name
      description: 'Servis talepleri ve durum güncellemeleri için bildirimler',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Foreground message handler'ı ayarlar
  void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message alındı: ${message.messageId}');
      debugPrint('Message data: ${message.data}');
      debugPrint('Message notification: ${message.notification?.title}');

      // Local notification göster
      if (message.notification != null) {
        _showLocalNotification(
          title: message.notification!.title ?? 'Bildirim',
          body: message.notification!.body ?? '',
          payload: message.data.toString(),
        );
      }
    });
  }

  /// App açıldığında gelen notification handler'ı ayarlar
  void _setupMessageOpenedAppHandler() {
    // App terminated durumundan açıldığında
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        debugPrint('App terminated durumundan notification ile açıldı');
        _handleNotificationTap(message.data);
      }
    });

    // App background durumundan açıldığında
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('App background durumundan notification ile açıldı');
      _handleNotificationTap(message.data);
    });
  }

  /// Notification tıklandığında çağrılır
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tıklandı: ${response.payload}');
    if (response.payload != null) {
      // Payload'ı parse et ve uygun sayfaya yönlendir
      // Bu kısım router ile entegre edilebilir
    }
  }

  /// Notification data'sını işler ve uygun aksiyonu alır
  void _handleNotificationTap(Map<String, dynamic> data) {
    debugPrint('Notification tap data: $data');
    // Burada notification data'sına göre uygun sayfaya yönlendirme yapılabilir
    // Örneğin: service_request_id varsa, servis detay sayfasına git
  }

  /// Bildirim izni ister
  /// 
  /// Returns: NotificationSettings - izin durumunu içerir
  Future<NotificationSettings> requestPermission() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('Bildirim izni durumu: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('Kullanıcı bildirim iznini verdi');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('Kullanıcı geçici bildirim iznini verdi');
      } else {
        debugPrint('Kullanıcı bildirim iznini vermedi');
      }

      return settings;
    } catch (e) {
      debugPrint('Bildirim izni isteme hatası: $e');
      rethrow;
    }
  }

  /// FCM device token'ını alır
  /// 
  /// Returns: Device token string veya null
  Future<String?> getDeviceToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $_fcmToken');
      return _fcmToken;
    } catch (e) {
      debugPrint('FCM Token alma hatası: $e');
      return null;
    }
  }

  /// FCM token'ı Supabase user_profiles tablosuna kaydeder
  /// 
  /// [userId] - Kullanıcının Supabase user ID'si
  /// [token] - FCM device token
  Future<bool> saveTokenToDatabase(String userId, String token) async {
    try {
      final supabase = Supabase.instance.client;

      await supabase.from('user_profiles').update({
        'device_token': token,
      }).eq('id', userId);

      debugPrint('FCM token veritabanına kaydedildi');
      return true;
    } catch (e) {
      debugPrint('FCM token kaydetme hatası: $e');
      return false;
    }
  }

  /// Local notification gösterir
  /// 
  /// [title] - Bildirim başlığı
  /// [body] - Bildirim içeriği
  /// [payload] - Bildirime tıklandığında kullanılacak veri
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'yardimyolda_channel',
      'Yardım Yolda Bildirimleri',
      channelDescription: 'Servis talepleri ve durum güncellemeleri için bildirimler',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Özel bir bildirim gösterir (public metod)
  /// 
  /// [title] - Bildirim başlığı
  /// [body] - Bildirim içeriği
  /// [payload] - Bildirime tıklandığında kullanılacak veri
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _showLocalNotification(
      title: title,
      body: body,
      payload: payload,
    );
  }

  /// Servis durum değişikliği için bildirim gösterir
  /// 
  /// [serviceType] - Servis tipi (örn: "Çekici", "Lastik Değişimi")
  /// [status] - Yeni durum
  Future<void> showServiceStatusNotification({
    required String serviceType,
    required String status,
    String? serviceRequestId,
  }) async {
    String title = 'Servis Talebi Güncellemesi';
    String body = _getStatusMessage(serviceType, status);

    await showNotification(
      title: title,
      body: body,
      payload: serviceRequestId,
    );
  }

  /// Durum değişikliği için Türkçe mesaj oluşturur
  String _getStatusMessage(String serviceType, String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return '$serviceType talebiniz alındı. Sağlayıcı aranıyor...';
      case 'accepted':
        return '$serviceType talebiniz kabul edildi!';
      case 'on_the_way':
        return 'Sağlayıcı yola çıktı. Yakında yanınızda olacak.';
      case 'in_progress':
        return '$serviceType hizmeti başladı.';
      case 'completed':
        return '$serviceType hizmeti tamamlandı. Lütfen değerlendirin.';
      case 'cancelled':
        return '$serviceType talebiniz iptal edildi.';
      default:
        return '$serviceType talebi durumu güncellendi: $status';
    }
  }

  /// Token yenilendiğinde dinleyen stream
  Stream<String> get onTokenRefresh => _firebaseMessaging.onTokenRefresh;

  /// Servisi temizler
  void dispose() {
    // Cleanup işlemleri
    _isInitialized = false;
  }
}
