import 'package:flutter_portfolio/features/portfolio/domain/entities/portfolio_content.dart';

/// Computes tenure from a career start [DateTime] (e.g. first day at current company).
class CareerTenure {
  CareerTenure._({
    required this.totalMonths,
    required this.sinceDisplay,
  });

  /// Inclusive month-based span (e.g. Aug 2022 → Apr 2026).
  final int totalMonths;
  final String sinceDisplay;

  static const List<String> _monthAbbr = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static CareerTenure? fromIsoDateString(
    String iso, {
    DateTime? now,
  }) {
    final start = DateTime.tryParse(iso);
    if (start == null) {
      return null;
    }
    final end = now ?? DateTime.now();
    final months = _monthSpan(start, end);
    if (months < 0) {
      return null;
    }
    final since =
        '${_monthAbbr[start.month - 1]} ${start.year}';
    return CareerTenure._(totalMonths: months, sinceDisplay: since);
  }

  /// Full calendar years (floor) for headline counter.
  int get fullYears => totalMonths ~/ 12;

  /// Show "+" when there is an additional partial year beyond [fullYears].
  bool get shouldPlusSuffix => totalMonths % 12 > 0;

  StatItem toStatItem({required String color}) {
    return StatItem(
      value: fullYears,
      suffix: shouldPlusSuffix ? '+' : '',
      label: 'Years in industry (since $sinceDisplay)',
      color: color,
    );
  }

  static int _monthSpan(DateTime start, DateTime end) {
    var months = (end.year - start.year) * 12 + end.month - start.month;
    if (end.day < start.day) {
      months -= 1;
    }
    return months;
  }
}
