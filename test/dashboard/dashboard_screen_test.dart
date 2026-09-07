import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/app/theme/app_theme.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:gym_management_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:gym_management_app/features/dashboard/presentation/screens/dashboard_screen.dart';

import '../helpers/auth_fixtures.dart';
import '../helpers/fake_dashboard_repository.dart';
import 'dashboard_test_fixtures.dart';

void main() {
  Widget buildScreen(FakeDashboardRepository repository) {
    return ProviderScope(
      overrides: [
        dashboardRepositoryProvider.overrideWithValue(repository),
        currentUserProvider.overrideWithValue(makeAppUser()),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const DashboardScreen(),
      ),
    );
  }

  testWidgets('shows operational metrics and empty list states', (
    tester,
  ) async {
    final repository = FakeDashboardRepository(
      snapshot: makeDashboardSnapshot(
        recentCheckIns: const [],
        expiringSubscriptions: const [],
      ),
    );

    await tester.pumpWidget(buildScreen(repository));
    await tester.pumpAndSettle();

    expect(find.text('Total members'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('No check-ins today'), findsOneWidget);
    expect(find.text('No subscriptions expiring soon'), findsOneWidget);
  });

  testWidgets('shows retry state when dashboard loading fails', (tester) async {
    final repository = FakeDashboardRepository(
      snapshot: makeDashboardSnapshot(),
      throwOnGet: true,
    );

    await tester.pumpWidget(buildScreen(repository));
    await tester.pumpAndSettle();

    expect(find.text('Unable to load dashboard.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}
