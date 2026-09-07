import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_management_app/app/app.dart';
import 'package:gym_management_app/app/router/app_routes.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/auth/domain/entities/auth_state.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:gym_management_app/features/dashboard/presentation/providers/dashboard_provider.dart';

import '../dashboard/dashboard_test_fixtures.dart';
import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_dashboard_repository.dart';

Widget appWith(FakeAuthRepository repository) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      dashboardRepositoryProvider.overrideWithValue(
        FakeDashboardRepository(snapshot: makeDashboardSnapshot()),
      ),
    ],
    child: const GymApp(),
  );
}

void main() {
  testWidgets('missing profile routes to onboarding', (tester) async {
    final repository = FakeAuthRepository(
      initialRestore: const AuthNeedsOnboarding(email: 'owner@gym.test'),
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(appWith(repository));
    await tester.pumpAndSettle();

    expect(find.text('Create your gym'), findsOneWidget);
  });

  testWidgets('inactive profile shows the disabled account screen', (
    tester,
  ) async {
    final repository = FakeAuthRepository(
      initialRestore: const AuthDisabled(email: 'staff@gym.test'),
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(appWith(repository));
    await tester.pumpAndSettle();

    expect(find.text('Account disabled'), findsOneWidget);
    expect(
      find.textContaining('contact your gym administrator'),
      findsOneWidget,
    );
  });

  testWidgets('disabled account blocks access to the application', (
    tester,
  ) async {
    final repository = FakeAuthRepository(
      initialRestore: const AuthDisabled(email: 'staff@gym.test'),
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(appWith(repository));
    await tester.pumpAndSettle();

    final router = GoRouter.of(
      tester.element(find.byType(Scaffold)),
    );
    router.go(RoutePaths.dashboard);
    await tester.pumpAndSettle();

    expect(find.text('Account disabled'), findsOneWidget);
    expect(find.text('Recent check-ins'), findsNothing);
  });

  testWidgets('session restoration failure shows the error screen with retry', (
    tester,
  ) async {
    final repository = FakeAuthRepository(
      restoreError: const NetworkFailure(),
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(appWith(repository));
    await tester.pumpAndSettle();

    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('invitation acceptance moves the user into the application', (
    tester,
  ) async {
    final repository = FakeAuthRepository(
      initialRestore: const AuthNeedsOnboarding(email: 'employee@gym.test'),
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(appWith(repository));
    await tester.pumpAndSettle();
    expect(find.text('Create your gym'), findsOneWidget);

    final router = GoRouter.of(tester.element(find.byType(Scaffold)));
    router.go('${RoutePaths.invitationAccept}?token=invite-abc');
    await tester.pumpAndSettle();

    // Invitation accepted → authenticated → guard moves to the dashboard.
    expect(find.text('Total members'), findsOneWidget);
  });

  testWidgets('invitation without a token shows a friendly error', (
    tester,
  ) async {
    final repository = FakeAuthRepository(
      initialRestore: const AuthNeedsOnboarding(email: 'employee@gym.test'),
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(appWith(repository));
    await tester.pumpAndSettle();

    final router = GoRouter.of(tester.element(find.byType(Scaffold)));
    router.go(RoutePaths.invitationAccept);
    await tester.pumpAndSettle();

    expect(find.textContaining('invitation link is invalid'), findsOneWidget);
  });
}
