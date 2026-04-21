import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_portfolio/features/portfolio/presentation/state/portfolio_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('controller toggles tweaks', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(portfolioControllerProvider.notifier);
    await notifier.setShowTweaks(true);

    expect(container.read(portfolioControllerProvider).showTweaks, true);
  });
}
