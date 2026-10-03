import 'package:flutter/material.dart';
import 'package:flutter_portfolio/features/build_sheet/presentation/pages/build_sheet_page.dart';
import 'package:flutter_portfolio/features/portfolio/presentation/pages/portfolio_page.dart';
import 'package:go_router/go_router.dart';

/// `/` is the Build Sheet portfolio; the previous design stays at `/classic`
/// and `/workflow`.
final class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          final section = state.uri.queryParameters['section'];
          return BuildSheetPage(initialSection: section);
        },
      ),
      GoRoute(
        path: '/classic',
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
