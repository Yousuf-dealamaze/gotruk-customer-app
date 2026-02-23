import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gotruck_customer/screens/auth/auth_loading_screen.dart';
import 'package:gotruck_customer/screens/home/home_shell_screen.dart';
import 'package:gotruck_customer/screens/auth/login_screen.dart';
import 'package:gotruck_customer/screens/auth/auth_provider.dart';
import 'package:gotruck_customer/screens/auth/signup_screen.dart';

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
        path: '/home',
        builder: (context, state) => const HomeShellScreen(),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final location = state.matchedLocation;
      final isOnAuthRoute = location == '/login' || location == '/signup';

      // Splash route decides where to navigate after checking local session.
      if (location == '/loading') {
        return null;
      }

      if (!authState.isLoggedIn) {
        return isOnAuthRoute ? null : '/login';
      }

      if (isOnAuthRoute) {
        return '/home';
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
