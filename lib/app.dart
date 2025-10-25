import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

/// Yardım Yolda App
/// Main application widget with routing and theme configuration
class YardimYoldaApp extends ConsumerWidget {
  const YardimYoldaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get router configuration from provider
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      // App configuration
      title: 'Yardım Yolda',
      debugShowCheckedModeBanner: false,

      // Theme configuration with Material 3
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Localization
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [
        Locale('tr', 'TR'),
        // Locale('en', 'US'), // Future support
      ],

      // Routing configuration
      routerConfig: router,
    );
  }
}
