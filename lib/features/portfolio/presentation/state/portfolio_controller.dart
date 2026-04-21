import 'dart:async';

import 'package:flutter_portfolio/core/theme/app_theme.dart';
import 'package:flutter_portfolio/features/portfolio/data/datasources/portfolio_local_data_source.dart';
import 'package:flutter_portfolio/features/portfolio/data/repositories/portfolio_repository_impl.dart';
import 'package:flutter_portfolio/features/portfolio/domain/usecases/get_portfolio_content_usecase.dart';
import 'package:flutter_portfolio/features/portfolio/presentation/state/portfolio_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _localDataSourceProvider = Provider<PortfolioLocalDataSource>(
  (_) => const PortfolioLocalDataSource(),
);

final _repositoryProvider = Provider<PortfolioRepositoryImpl>(
  (ref) => PortfolioRepositoryImpl(ref.watch(_localDataSourceProvider)),
);

final _getPortfolioContentProvider = Provider<GetPortfolioContentUseCase>(
  (ref) => GetPortfolioContentUseCase(ref.watch(_repositoryProvider)),
);

final portfolioControllerProvider =
    NotifierProvider<PortfolioController, PortfolioState>(
      PortfolioController.new,
    );

class PortfolioController extends Notifier<PortfolioState> {
  static const String _prefShowSplash = 'portfolio_show_splash_done';
  static const String _prefDarkMode = 'portfolio_dark_mode';
  static const String _prefShowTweaks = 'portfolio_show_tweaks';

  Timer? _testimonialTimer;

  @override
  PortfolioState build() {
    unawaited(load());
    return const PortfolioState();
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_prefDarkMode) ?? true;
      final showSplashDone = prefs.getBool(_prefShowSplash) ?? false;
      final showTweaks = prefs.getBool(_prefShowTweaks) ?? false;
      ref.read(appThemeModeProvider.notifier).state = isDark;

      final content = await ref.read(_getPortfolioContentProvider).call();
      state = state.copyWith(
        isLoading: false,
        content: content,
        showSplash: !showSplashDone,
        showTweaks: showTweaks,
      );
      _startAutoRotate();
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load portfolio content.',
      );
    }
  }

  void _startAutoRotate() {
    _testimonialTimer?.cancel();
    _testimonialTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      final length = state.content?.testimonials.length ?? 0;
      if (length == 0) {
        return;
      }
      state = state.copyWith(
        activeTestimonialIndex: (state.activeTestimonialIndex + 1) % length,
      );
    });
    ref.onDispose(() => _testimonialTimer?.cancel());
  }

  Future<void> setDarkMode(bool value) async {
    ref.read(appThemeModeProvider.notifier).state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefDarkMode, value);
  }

  Future<void> setShowTweaks(bool value) async {
    state = state.copyWith(showTweaks: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefShowTweaks, value);
  }

  Future<void> completeSplash() async {
    state = state.copyWith(showSplash: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefShowSplash, true);
  }

  void openProject(int index) {
    state = state.copyWith(selectedProjectIndex: index);
  }

  void closeProject() {
    state = state.copyWith(clearSelectedProject: true);
  }

  void setActiveTestimonial(int index) {
    state = state.copyWith(activeTestimonialIndex: index);
  }
}
