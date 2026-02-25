import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gotruck_customer/screens/auth/auth_loading_screen.dart';
import 'package:gotruck_customer/screens/home/home_shell_screen.dart';
import 'package:gotruck_customer/screens/auth/login_screen.dart';
import 'package:gotruck_customer/screens/auth/auth_provider.dart';
import 'package:gotruck_customer/screens/auth/otp_verification_screen.dart';
import 'package:gotruck_customer/screens/auth/signup_screen.dart';
import 'package:gotruck_customer/screens/home/tabs/home_tab/pricing_selection_page.dart';
import 'package:gotruck_customer/screens/onboarding/onboarding_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final goRouter = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/loading',
    routes: [
      GoRoute(
        path: '/loading',
        builder: (context, state) => const AuthLoadingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OtpVerificationScreen(
            type: (extra['type'] as String?) ?? 'phone',
            phoneNumber: (extra['phoneNumber'] as String?) ?? '',
            email: (extra['email'] as String?) ?? '',
            countryCode: (extra['countryCode'] as String?) ?? '+91',
          );
        },
      ),
      GoRoute(path: '/home', redirect: (context, state) => '/home/home'),
      GoRoute(
        path: '/home/:tab',
        builder: (context, state) {
          final tab = state.pathParameters['tab'] ?? 'home';
          return HomeShellScreen(tab: tab);
        },
      ),
      GoRoute(
        path: '/pricing-selection',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return PricingSelectionPage(
            sourceDetails: extra['sourceDetails'],
            destinationDetails: extra['destinationDetails'],
            distanceKm: extra['distanceKm'] as double,
            vehicleQuantity: extra['vehicleQuantity'],
            scheduledAt: extra['scheduledAt'] as DateTime,
            bookingMode: extra['bookingMode'] as String,
          );
        },
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final location = state.matchedLocation;
      final isOnAuthRoute = location == '/login' || location == '/signup';
      final isOnPublicRoute = isOnAuthRoute || location == '/onboarding';

      // Splash route decides where to navigate after checking local session.
      if (location == '/loading') {
        return null;
      }

      if (location == '/otp-verification') {
        return null;
      }

      if (!authState.isLoggedIn) {
        return isOnPublicRoute ? null : '/login';
      }

      if (isOnPublicRoute) {
        return '/home/home';
      }
      return null;
    },
  );

  AppRouter.attach(goRouter);
  return goRouter;
});

class AppRouter {
  static GoRouter? _router;

  static void attach(GoRouter router) {
    _router = router;
  }

  static void push(String location, {Object? extra}) {
    _router?.push(location, extra: extra);
  }

  static void go(String location, {Object? extra}) {
    _router?.go(location, extra: extra);
  }

  static void pop() {
    if (_router != null && _router!.canPop()) {
      _router!.pop();
    }
  }
}
