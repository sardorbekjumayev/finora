import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/database/enums.dart';
import '../core/services/settings_service.dart';
import '../features/accounts/presentation/account_editor_screen.dart';
import '../features/accounts/presentation/accounts_screen.dart';
import '../features/backup/presentation/backup_screen.dart';
import '../features/categories/presentation/categories_screen.dart';
import '../features/categories/presentation/category_editor_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/more/presentation/more_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/statistics/presentation/statistics_screen.dart';
import '../features/transactions/presentation/transaction_details_screen.dart';
import '../features/transactions/presentation/transaction_editor_screen.dart';
import '../features/transactions/presentation/transactions_screen.dart';
import 'home_shell.dart';

class Routes {
  const Routes._();

  static const onboarding = '/onboarding';
  static const home = '/';
  static const transactions = '/transactions';
  static const statistics = '/statistics';
  static const more = '/more';

  static const txNew = '/tx/new';
  static String txDetails(int id) => '/tx/$id';
  static String txEdit(int id) => '/tx/$id/edit';

  static const accounts = '/accounts';
  static const accountNew = '/accounts/new';
  static String accountEdit(int id) => '/accounts/$id/edit';

  static const categories = '/categories';
  static const categoryNew = '/categories/new';
  static String categoryEdit(int id) => '/categories/$id/edit';

  static const settings = '/settings';
  static const backup = '/backup';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.home,
    redirect: (context, state) {
      final done = ref.read(settingsProvider).onboardingDone;
      final atOnboarding = state.matchedLocation == Routes.onboarding;
      if (!done && !atOnboarding) return Routes.onboarding;
      if (done && atOnboarding) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.transactions,
                builder: (context, state) => const TransactionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.statistics,
                builder: (context, state) => const StatisticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.more,
                builder: (context, state) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.txNew,
        pageBuilder: (context, state) => _modalPage(
          state,
          TransactionEditorScreen(
            initialType: _typeFromQuery(state.uri.queryParameters['type']),
            presetAccountId:
                int.tryParse(state.uri.queryParameters['account'] ?? ''),
          ),
        ),
      ),
      GoRoute(
        path: '/tx/:id',
        builder: (context, state) => TransactionDetailsScreen(
          id: int.parse(state.pathParameters['id']!),
        ),
        routes: [
          GoRoute(
            path: 'edit',
            pageBuilder: (context, state) => _modalPage(
              state,
              TransactionEditorScreen(
                editId: int.parse(state.pathParameters['id']!),
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: Routes.accounts,
        builder: (context, state) => const AccountsScreen(),
        routes: [
          GoRoute(
            path: 'new',
            pageBuilder: (context, state) =>
                _modalPage(state, const AccountEditorScreen()),
          ),
          GoRoute(
            path: ':id/edit',
            pageBuilder: (context, state) => _modalPage(
              state,
              AccountEditorScreen(
                editId: int.parse(state.pathParameters['id']!),
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: Routes.categories,
        builder: (context, state) => const CategoriesScreen(),
        routes: [
          GoRoute(
            path: 'new',
            pageBuilder: (context, state) => _modalPage(
              state,
              CategoryEditorScreen(
                initialKind: _kindFromQuery(state.uri.queryParameters['kind']),
              ),
            ),
          ),
          GoRoute(
            path: ':id/edit',
            pageBuilder: (context, state) => _modalPage(
              state,
              CategoryEditorScreen(
                editId: int.parse(state.pathParameters['id']!),
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.backup,
        builder: (context, state) => const BackupScreen(),
      ),
    ],
  );
});

/// Formalar pastdan yuqoriga chiqadi — bu "vaqtinchalik oyna" degan ishora.
Page<void> _modalPage(GoRouterState state, Widget child) {
  return MaterialPage<void>(
    key: state.pageKey,
    fullscreenDialog: true,
    child: child,
  );
}

TransactionType _typeFromQuery(String? value) {
  for (final type in TransactionType.values) {
    if (type.name == value) return type;
  }
  return TransactionType.expense;
}

CategoryKind _kindFromQuery(String? value) {
  for (final kind in CategoryKind.values) {
    if (kind.name == value) return kind;
  }
  return CategoryKind.expense;
}
