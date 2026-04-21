import 'package:flutter_portfolio/features/portfolio/domain/entities/portfolio_content.dart';

class PortfolioState {
  const PortfolioState({
    this.isLoading = true,
    this.content,
    this.errorMessage,
    this.selectedProjectIndex,
    this.activeTestimonialIndex = 0,
    this.showSplash = true,
    this.showTweaks = false,
  });

  final bool isLoading;
  final PortfolioContent? content;
  final String? errorMessage;
  final int? selectedProjectIndex;
  final int activeTestimonialIndex;
  final bool showSplash;
  final bool showTweaks;

  PortfolioState copyWith({
    bool? isLoading,
    PortfolioContent? content,
    String? errorMessage,
    int? selectedProjectIndex,
    bool clearSelectedProject = false,
    int? activeTestimonialIndex,
    bool? showSplash,
    bool? showTweaks,
  }) {
    return PortfolioState(
      isLoading: isLoading ?? this.isLoading,
      content: content ?? this.content,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedProjectIndex: clearSelectedProject
          ? null
          : (selectedProjectIndex ?? this.selectedProjectIndex),
      activeTestimonialIndex:
          activeTestimonialIndex ?? this.activeTestimonialIndex,
      showSplash: showSplash ?? this.showSplash,
      showTweaks: showTweaks ?? this.showTweaks,
    );
  }
}
