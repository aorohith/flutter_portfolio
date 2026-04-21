import 'package:flutter_portfolio/core/utils/career_duration.dart';
import 'package:flutter_portfolio/features/portfolio/domain/entities/portfolio_content.dart';

/// Merges JSON [StatItem]s with computed tenure when [Profile.careerStartDate] is set.
List<StatItem> resolveDisplayStats(PortfolioContent content) {
  final stats = List<StatItem>.from(content.stats);
  final start = content.profile.careerStartDate;
  if (start != null && stats.isNotEmpty) {
    final tenure = CareerTenure.fromIsoDateString(start);
    if (tenure != null) {
      stats[0] = tenure.toStatItem(color: stats[0].color);
    }
  }
  return stats;
}
