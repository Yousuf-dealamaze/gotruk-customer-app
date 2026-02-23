import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gotruck_customer/constants/core.dart';
import 'package:gotruck_customer/core/theme/colors.dart';
import 'package:gotruck_customer/router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'GoTruck',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: Constant.fontsFamily,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          surface: cardColor,
          onPrimary: cardColor,
          onSurface: fontBlack,
          secondary: successColor,
          onSecondary: cardColor,
          error: primaryColor.withValues(alpha: 0.75),
          onError: cardColor,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: cardColor,
          foregroundColor: fontBlack,
          elevation: 0,
          centerTitle: false,
        ),
        cardColor: cardColor,
        shadowColor: shadowColor,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardColor,
          hintStyle: TextStyle(color: greyFont),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: fontBlack),
          bodyMedium: TextStyle(color: fontBlack),
        ),
      ),
    );
  }
}
