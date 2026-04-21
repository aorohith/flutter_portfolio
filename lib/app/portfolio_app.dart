import 'package:flutter/material.dart';
import 'package:flutter_portfolio/app/app_router.dart';
import 'package:flutter_portfolio/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PortfolioApp extends ConsumerWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(appThemeModeProvider);
    return MaterialApp.router(
      title: 'Rohith A O - Flutter Developer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}
