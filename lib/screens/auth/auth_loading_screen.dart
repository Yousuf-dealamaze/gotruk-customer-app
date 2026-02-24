import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gotruck_customer/core/theme/colors.dart';
import 'package:gotruck_customer/screens/auth/auth_provider.dart';
import 'package:gotruck_customer/services/local_storage_service.dart';

class AuthLoadingScreen extends ConsumerStatefulWidget {
  const AuthLoadingScreen({super.key});

  @override
  ConsumerState<AuthLoadingScreen> createState() => _AuthLoadingScreenState();
}

class _AuthLoadingScreenState extends ConsumerState<AuthLoadingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapSession());
  }

  Future<void> _bootstrapSession() async {
    final hasSeenOnboarding = await LocalStorageService().hasSeenOnboarding();
    if (!hasSeenOnboarding) {
      if (!mounted) return;
      context.go('/onboarding');
      return;
    }

    final hasSession = await ref
        .read(authProvider.notifier)
        .restoreSessionFromStorage();

    if (!mounted) return;

    if (hasSession) {
      context.go('/home');
      return;
    }

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: MediaQuery.of(context).size.width * 0.5,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const FlutterLogo(size: 110),
            ),
            const SizedBox(height: 12),
            CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: 12),
            Text('Checking your session...', style: TextStyle(color: greyFont)),
          ],
        ),
      ),
    );
  }
}
