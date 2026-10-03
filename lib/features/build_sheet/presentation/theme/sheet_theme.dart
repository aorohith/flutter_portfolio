import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colour tokens for the "Build Sheet" design. Resolved from the ambient
/// [Theme] brightness so the app-level light/dark switch drives everything.
@immutable
class SheetPalette {
  const SheetPalette({
    required this.bg,
    required this.surface,
    required this.fg,
    required this.muted,
    required this.line,
    required this.accent,
    required this.accentInk,
    required this.ok,
    required this.shadow,
  });

  final Color bg;
  final Color surface;
  final Color fg;
  final Color muted;
  final Color line;
  final Color accent;
  final Color accentInk;
  final Color ok;
  final Color shadow;

  static const SheetPalette light = SheetPalette(
    bg: Color(0xFFE8EBE6),
    surface: Color(0xFFF3F5F1),
    fg: Color(0xFF11161C),
    muted: Color(0xFF4A535C),
    line: Color(0xFFC3CAC2),
    accent: Color(0xFF2236D4),
    accentInk: Color(0xFFF3F5F1),
    ok: Color(0xFF1F7A45),
    shadow: Color(0x4711161C),
  );

  static const SheetPalette dark = SheetPalette(
    bg: Color(0xFF0E1217),
    surface: Color(0xFF161C23),
    fg: Color(0xFFE6EAEE),
    muted: Color(0xFF9AA5B0),
    line: Color(0xFF2A333C),
    accent: Color(0xFF8EA2FF),
    accentInk: Color(0xFF0E1217),
    ok: Color(0xFF5FD38D),
    shadow: Color(0x99000000),
  );

  static SheetPalette of(BuildContext context) {
    return Theme.brightnessOf(context) == Brightness.dark ? dark : light;
  }
}

/// Typography: Bricolage Grotesque (display), Hanken Grotesk (body),
/// JetBrains Mono (metadata). `tracking` is in em, like the CSS source.
abstract final class SheetType {
  static TextStyle display(
    Color color,
    double size, {
    FontWeight weight = FontWeight.w700,
    double tracking = 0,
    double height = 1.02,
  }) {
    return GoogleFonts.bricolageGrotesque(
      color: color,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: size * tracking,
      height: height,
    );
  }

  static TextStyle body(
    Color color,
    double size, {
    FontWeight weight = FontWeight.w400,
    double height = 1.6,
  }) {
    return GoogleFonts.hankenGrotesk(
      color: color,
      fontSize: size,
      fontWeight: weight,
      height: height,
    );
  }

  static TextStyle mono(
    Color color,
    double size, {
    FontWeight weight = FontWeight.w400,
    double tracking = 0,
    double height = 1.4,
  }) {
    return GoogleFonts.jetBrainsMono(
      color: color,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: size * tracking,
      height: height,
    );
  }

  /// Small uppercase metadata label (`.mono` in the HTML).
  static TextStyle label(SheetPalette p) =>
      mono(p.muted, 12.16, tracking: 0.08, height: 1.6);
}

/// Layout constants and fluid sizing helpers.
abstract final class Sheet {
  static const double maxWidth = 1240;
  static const double headerHeight = 64;

  /// `clamp(16px, 4vw, 48px)`.
  static double gutter(double width) => (width * 0.04).clamp(16.0, 48.0);

  /// CSS `clamp(minPx, vw vw, maxPx)`.
  static double fluid(double width, double minPx, double vw, double maxPx) =>
      (width * vw / 100).clamp(minPx, maxPx);

  /// Single column at and below this viewport width.
  static bool isNarrow(double width) => width <= 900;

  /// Approximate CSS `ch` unit for a given font size.
  static double ch(double fontSize, int n) => n * fontSize * 0.56;
}
