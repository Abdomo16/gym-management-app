import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_management_app/app/app.dart';
import 'package:gym_management_app/app/router/app_routes.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/core/widgets/app_scaffold.dart';
import 'package:gym_management_app/core/widgets/app_text_field.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_providers.dart';

import 'helpers/auth_fixtures.dart';
import 'helpers/fake_auth_repository.dart';

Widget appWith(FakeAuthRepository repository) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
    child: const GymApp(),
  );
}

void main() {
  testWidgets('shows the login screen when unauthenticated', (tester) async {
    final repository = FakeAuthRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(appWith(repository));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byType(AppTextField), findsNWidgets(2));
  });

  testWidgets('shows the dashboard when authenticated', (tester) async {
    final repository = FakeAuthRepository(
      initialRestore: authenticatedState(),
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(appWith(repository));
    await tester.pumpAndSettle();

    expect(find.text('Recent check-ins'), findsOneWidget);
    expect(find.textContaining('Alex Owner'), findsOneWidget);
  });

  testWidgets('signs in and lands on the dashboard', (tester) async {
    final repository = FakeAuthRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(appWith(repository));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);

    // After a successful sign-in the profile exists, so restoration will
    // resolve to the authenticated state.
    repository.setRestoreResult(authenticatedState());

    await tester.enterText(find.byType(TextField).first, 'owner@gym.test');
    await tester.enterText(find.byType(TextField).at(1), 'correct-password');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Recent check-ins'), findsOneWidget);
  });

  testWidgets('shows a friendly error on failed sign-in', (tester) async {
    final repository = FakeAuthRepository();
    repository.signInError = const AuthFailure(message: 'Invalid email or password.');
    addTearDown(repository.dispose);

    await tester.pumpWidget(appWith(repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'owner@gym.test');
    await tester.enterText(find.byType(TextField).at(1), 'wrong-password');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid email or password.'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('authenticated users cannot reach the login screen', (
    tester,
  ) async {
    final repository = FakeAuthRepository(
      initialRestore: authenticatedState(),
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(appWith(repository));
    await tester.pumpAndSettle();

    final router = GoRouter.of(
      tester.element(find.byType(AppScaffold)),
    );
    router.go(RoutePaths.login);
    await tester.pumpAndSettle();

    expect(find.text('Recent check-ins'), findsOneWidget);
    expect(find.text('Welcome back'), findsNothing);
  });

  testWidgets('signing out returns to the login screen', (tester) async {
    // Wide surface so the sidebar (with the sign-out button) is visible.
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeAuthRepository(
      initialRestore: authenticatedState(),
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(appWith(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
