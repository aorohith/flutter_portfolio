import 'package:flutter/material.dart';
import 'package:flutter_portfolio/core/constants/app_spacing.dart';
import 'package:flutter_portfolio/core/layout/content_width_scope.dart';

/// Shared layout breakpoints for web and narrow viewports.
final class Breakpoints {
  const Breakpoints._();

  /// Below this width, use compact navigation (drawer) and single-column sections.
  static const double compact = 600;

  /// Below this width, avoid heavy two-column hero/about/contact layouts.
  static const double medium = 900;

  /// Wide hero split (copy + avatar card).
  static const double heroTwoColumn = 980;

  static bool isCompactWidth(double width) => width < compact;

  static bool isMediumWidth(double width) => width >= compact && width < medium;

  /// Side-by-side columns for about/contact/footer rows.
  static bool useWideTwoColumns(double width) => width >= medium;

  /// Hero: avatar column beside headline.
  static bool heroShowsSideAvatar(double width) => width > heroTwoColumn;

  static int responsiveGridCrossAxisCount({
    required double maxWidth,
    required int maxColumns,
    double minTileWidth = 300,
  }) {
    if (maxWidth <= 0 || maxColumns < 1) {
      return 1;
    }
    final raw = (maxWidth / minTileWidth).floor();
    return raw.clamp(1, maxColumns);
  }

  /// Horizontal padding inside constrained content on very narrow widths.
  static double contentHorizontalPadding(double width) {
    if (width < 360) {
      return 16;
    }
    if (width < compact) {
      return 20;
    }
    return 32;
  }

  /// Inner content width under [ConstrainedContent] (handles horizontal padding + max width cap).
  /// Use this instead of [LayoutBuilder] max width when the parent is inside a [Center], which
  /// passes unbounded max width constraints.
  static double contentWidthForScreenWidth(double screenWidth) {
    final pad = contentHorizontalPadding(screenWidth);
    final inner = screenWidth - 2 * pad;
    return inner.clamp(0.0, AppSpacing.maxContentWidth);
  }

  static double portfolioContentWidth(BuildContext context) {
    final scoped = ContentWidthScope.maybeOf(context);
    if (scoped != null && scoped.isFinite) {
      return scoped;
    }
    return contentWidthForScreenWidth(MediaQuery.sizeOf(context).width);
  }
}

/// Optional clamp so hero/section titles stay readable without blowing layout.
TextScaler clampedHeroTextScaler(BuildContext context) {
  return MediaQuery.textScalerOf(
    context,
  ).clamp(minScaleFactor: 0.85, maxScaleFactor: 1.05);
}
