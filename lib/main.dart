import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/services/notification_service.dart';

/// Yardım Yolda - Yol Yardım Uygulaması
/// Entry point of the application
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");

    // Initialize Supabase
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );

    // Initialize Firebase with placeholder config
    // Note: Firebase initialization may fail with placeholder config
    // This is expected in development. Real config needed for production.
    try {
      await Firebase.initializeApp();
      debugPrint('✅ Firebase başarıyla başlatıldı');

      // Initialize notification service
      final notificationService = NotificationService();
      await notificationService.initialize();
      debugPrint('✅ Notification service başarıyla başlatıldı');
    } catch (firebaseError) {
      debugPrint('⚠️ Firebase başlatma hatası (placeholder config kullanılıyor): $firebaseError');
      debugPrint('⚠️ Üretim için gerçek Firebase yapılandırması gereklidir');
      // Continue without Firebase - app will work but push notifications won't
    }

    // Run the app wrapped in ProviderScope for Riverpod
    runApp(
      const ProviderScope(
        child: YardimYoldaApp(),
      ),
    );
  } catch (e) {
    // If initialization fails, show error
    debugPrint('❌ Başlatma hatası: $e');
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Uygulama Başlatılamadı',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Lütfen yapılandırmayı kontrol edin\n\n'
                    '1. .env dosyasının varlığını kontrol edin\n'
                    '2. Supabase ayarlarını kontrol edin\n'
                    '3. Firebase yapılandırmasını kontrol edin\n\n'
                    'Hata detayı:\n$e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Supabase client accessor
/// Use this throughout the app to access Supabase
final supabase = Supabase.instance.client;
