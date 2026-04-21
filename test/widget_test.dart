import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_portfolio/app/portfolio_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('portfolio app renders splash', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{'portfolio_show_splash_done': true},
    );
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: PortfolioApp()));
    await tester.pumpAndSettle();

    expect(find.text('Rohith A O'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
