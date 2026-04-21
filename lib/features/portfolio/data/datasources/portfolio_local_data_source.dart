import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_portfolio/features/portfolio/data/models/portfolio_content_model.dart';

class PortfolioLocalDataSource {
  const PortfolioLocalDataSource();

  Future<PortfolioContentModel> getPortfolioContent() async {
    final raw = await rootBundle.loadString(
      'assets/data/portfolio_content.json',
    );
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return PortfolioContentModel.fromJson(decoded);
  }
}
