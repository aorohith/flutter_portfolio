import 'package:flutter_portfolio/features/portfolio/domain/entities/portfolio_content.dart';

abstract interface class PortfolioRepository {
  Future<PortfolioContent> getPortfolioContent();
}
