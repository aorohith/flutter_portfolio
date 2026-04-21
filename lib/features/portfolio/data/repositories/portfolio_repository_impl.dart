import 'package:flutter_portfolio/features/portfolio/data/datasources/portfolio_local_data_source.dart';
import 'package:flutter_portfolio/features/portfolio/domain/entities/portfolio_content.dart';
import 'package:flutter_portfolio/features/portfolio/domain/repositories/portfolio_repository.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  const PortfolioRepositoryImpl(this._localDataSource);

  final PortfolioLocalDataSource _localDataSource;

  @override
  Future<PortfolioContent> getPortfolioContent() {
    return _localDataSource.getPortfolioContent();
  }
}
