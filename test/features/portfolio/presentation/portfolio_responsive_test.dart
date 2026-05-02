import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_portfolio/app/portfolio_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'portfolio loads and lays out without exceptions at common viewports',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'portfolio_show_splash_done': true,
      });

      const sizes = <Size>[
        Size(320, 568),
        Size(390, 844),
        Size(768, 1024),
        Size(1280, 720),
      ];

      for (final logicalSize in sizes) {
        tester.view.physicalSize = logicalSize;
        tester.view.devicePixelRatio = 1;

        await tester.pumpWidget(const ProviderScope(child: PortfolioApp()));
        await tester.pump();

        var sawContent = false;
        for (var i = 0; i < 150; i++) {
          await tester.pump(const Duration(milliseconds: 100));
          if (find.text('Rohith A O').evaluate().isNotEmpty) {
            sawContent = true;
            break;
          }
        }

        expect(
          sawContent,
          isTrue,
          reason:
              'Expected portfolio content at ${logicalSize.width}x${logicalSize.height}',
        );
        expect(find.text('Rohith A O'), findsWidgets);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      }

      tester.view.reset();
    },
  );
}
