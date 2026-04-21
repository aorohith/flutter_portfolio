import 'package:flutter/material.dart';
import 'package:flutter_portfolio/app/portfolio_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: PortfolioApp()));
}
