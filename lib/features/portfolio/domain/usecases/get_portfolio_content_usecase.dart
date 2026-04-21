import 'package:flutter_portfolio/features/portfolio/domain/entities/portfolio_content.dart';
import 'package:flutter_portfolio/features/portfolio/domain/repositories/portfolio_repository.dart';

class GetPortfolioContentUseCase {
  const GetPortfolioContentUseCase(this._repository);

  final PortfolioRepository _repository;

  Future<PortfolioContent> call() {
    return _repository.getPortfolioContent();
  }
}
