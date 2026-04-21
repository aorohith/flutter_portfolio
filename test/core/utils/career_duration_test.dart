import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_portfolio/core/utils/career_duration.dart';

void main() {
  test('CareerTenure computes months and stat from ISO start', () {
    final tenure = CareerTenure.fromIsoDateString(
      '2022-08-01',
      now: DateTime(2026, 4, 21),
    );
    expect(tenure, isNotNull);
    expect(tenure!.fullYears, 3);
    expect(tenure.shouldPlusSuffix, isTrue);
    final stat = tenure.toStatItem(color: '#000000');
    expect(stat.value, 3);
    expect(stat.suffix, '+');
    expect(stat.label, contains('Aug 2022'));
  });
}
