import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_portfolio/core/layout/breakpoints.dart';

void main() {
  group('Breakpoints', () {
    test('isCompactWidth uses <600', () {
      expect(Breakpoints.isCompactWidth(599), isTrue);
      expect(Breakpoints.isCompactWidth(600), isFalse);
    });

    test('useWideTwoColumns uses >=900', () {
      expect(Breakpoints.useWideTwoColumns(899), isFalse);
      expect(Breakpoints.useWideTwoColumns(900), isTrue);
    });

    test('heroShowsSideAvatar uses >980', () {
      expect(Breakpoints.heroShowsSideAvatar(980), isFalse);
      expect(Breakpoints.heroShowsSideAvatar(981), isTrue);
    });

    test('responsiveGridCrossAxisCount clamps by minTileWidth', () {
      expect(
        Breakpoints.responsiveGridCrossAxisCount(
          maxWidth: 280,
          maxColumns: 4,
          minTileWidth: 300,
        ),
        1,
      );
      expect(
        Breakpoints.responsiveGridCrossAxisCount(
          maxWidth: 620,
          maxColumns: 4,
          minTileWidth: 300,
        ),
        2,
      );
      expect(
        Breakpoints.responsiveGridCrossAxisCount(
          maxWidth: 1300,
          maxColumns: 4,
          minTileWidth: 300,
        ),
        4,
      );
    });

    test('contentHorizontalPadding scales down on narrow widths', () {
      expect(Breakpoints.contentHorizontalPadding(319), 16);
      expect(Breakpoints.contentHorizontalPadding(400), 20);
      expect(Breakpoints.contentHorizontalPadding(700), 32);
    });

    test('contentWidthForScreenWidth applies padding and max cap', () {
      expect(Breakpoints.contentWidthForScreenWidth(320), 288);
      expect(Breakpoints.contentWidthForScreenWidth(2000), 1200);
    });
  });
}
