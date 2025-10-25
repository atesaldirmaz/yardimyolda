import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/presentation/screens/auth_phone_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/otp_verify_screen.dart';
import '../features/auth/providers/auth_state_provider.dart';
import '../features/customer/presentation/screens/dashboard_screen.dart';
import '../features/customer/presentation/screens/service_select_screen.dart';
import '../features/customer/presentation/screens/request_tracking_screen.dart';
import '../features/customer/presentation/screens/history_screen.dart';
import '../features/rating/presentation/screens/rating_screen.dart';
import '../features/payment/presentation/screens/payment_screen.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';

/// Router provider for the app
/// Manages navigation and authentication state
final routerProvider = Provider<GoRouter>((ref) {
  // Watch auth state for redirects
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    
    // Refresh router when auth state changes
    refreshListenable: _AuthStateNotifier(ref),
    
    routes: [
      // Splash Screen
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Authentication Routes
      GoRoute(
        path: '/auth/phone',
        name: 'auth-phone',
        builder: (context, state) => const AuthPhoneScreen(),
      ),
      GoRoute(
        path: '/auth/verify',
        name: 'auth-verify',
        builder: (context, state) {
          final phoneNumber = state.extra as String?;
          if (phoneNumber == null) {
            // Redirect back to phone screen if no phone number
            return const AuthPhoneScreen();
          }
          return OtpVerifyScreen(phoneNumber: phoneNumber);
        },
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main Dashboard (Legacy - keeping for compatibility)
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),

      // Customer Dashboard and Service Routes
      GoRoute(
        path: '/customer/dashboard',
        name: 'customer-dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/customer/service-select',
        name: 'service-select',
        builder: (context, state) => const ServiceSelectScreen(),
      ),
      GoRoute(
        path: '/customer/request-tracking/:id',
        name: 'request-tracking',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return RequestTrackingScreen(requestId: id);
        },
      ),

      // Payment Route
      GoRoute(
        path: '/customer/payment/:requestId',
        name: 'payment',
        builder: (context, state) {
          final requestId = state.pathParameters['requestId']!;
          return PaymentScreen(requestId: requestId);
        },
      ),

      // Customer History Route
      GoRoute(
        path: '/customer/history',
        name: 'customer-history',
        builder: (context, state) => const HistoryScreen(),
      ),

      // Rating Route
      GoRoute(
        path: '/rating/:requestId',
        name: 'rating',
        builder: (context, state) {
          final requestId = state.pathParameters['requestId']!;
          return RatingScreen(requestId: requestId);
        },
      ),

      // Profile & Settings Routes (to be implemented)
      // GoRoute(
      //   path: '/profile',
      //   name: 'profile',
      //   builder: (context, state) => const ProfilePage(),
      // ),
    ],

    // Redirect logic for authentication
    redirect: (context, state) async {
      final location = state.matchedLocation;
      
      // If on splash, stay there
      if (location == '/') {
        return null;
      }

      // Auth pages - no redirect needed
      final authPages = ['/auth/phone', '/auth/verify'];
      if (authPages.contains(location)) {
        return null;
      }

      // Check auth state
      final isAuthenticated = authState.isAuthenticated;
      final isNewUser = authState.isNewUser;
      final isOnboarding = location == '/onboarding';
      final isDashboard = location == '/dashboard' || location == '/customer/dashboard';
      final isCustomerRoute = location.startsWith('/customer');

      // New user without profile - redirect to onboarding
      if (isNewUser && !isOnboarding) {
        return '/onboarding';
      }

      // User has profile but on onboarding - redirect to customer dashboard
      if (isAuthenticated && isOnboarding) {
        return '/customer/dashboard';
      }

      // Not authenticated and not on auth page - redirect to phone auth
      if (!isAuthenticated && !isNewUser && !authPages.contains(location)) {
        return '/auth/phone';
      }

      // Authenticated user on auth page - redirect to customer dashboard
      if (isAuthenticated && authPages.contains(location)) {
        return '/customer/dashboard';
      }

      // Redirect old dashboard to new customer dashboard
      if (isAuthenticated && location == '/dashboard') {
        return '/customer/dashboard';
      }

      // No redirect needed
      return null;
    },

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Sayfa bulunamadı',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.toString() ?? 'Bilinmeyen hata',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.home),
              label: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Auth State Notifier for router refresh
/// Notifies router when auth state changes
class _AuthStateNotifier extends ChangeNotifier {
  final Ref _ref;
  
  _AuthStateNotifier(this._ref) {
    // Listen to auth state changes
    _ref.listen(authStateProvider, (previous, next) {
      notifyListeners();
    });
  }
}
