import 'package:flutter/material.dart';
import 'package:flutter_portfolio/features/portfolio/presentation/pages/portfolio_page.dart';
import 'package:go_router/go_router.dart';

/// App routes including `/workflow` deep link (scroll handled in [PortfolioPage]).
final class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          final section = state.uri.queryParameters['section'];
          return PortfolioPage(initialScrollSection: section);
        },
      ),
      GoRoute(
        path: '/workflow',
        builder: (BuildContext context, GoRouterState state) {
          return const PortfolioPage(initialScrollSection: 'workflow');
        },
      ),
    ],
  );
}
