import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gym_management_app/app/app.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/auth/domain/entities/auth_state.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_providers.dart';

import '../helpers/fake_auth_repository.dart';

Widget appWith(FakeAuthRepository repository) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
    child: const GymApp(),
  );
}

void main() {
  testWidgets('shows validation errors for an empty onboarding form', (
    tester,
  ) async {
    final repository = FakeAuthRepository(
      initialRestore: const AuthNeedsOnboarding(email: 'owner@gym.test'),
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(appWith(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create gym'));
    await tester.pumpAndSettle();

    // Organization name and owner name are required.
    expect(find.text('This field is required.'), findsNWidgets(2));
    // Still on the onboarding screen.
    expect(find.text('Create your gym'), findsOneWidget);
  });

  testWidgets('creates the gym and enters the dashboard on success', (
    tester,
  ) async {
    final repository = FakeAuthRepository(
      initialRestore: const AuthNeedsOnboarding(email: 'owner@gym.test'),
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(appWith(repository));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Gym / organization name'),
      'FitZone',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Owner full name'),
      'Alex Owner',
    );

    // The timezone defaults to a sensible device-derived value, so the form
    // is already valid.
    await tester.tap(find.text('Create gym'));
    await tester.pumpAndSettle();

    expect(find.text('Recent check-ins'), findsOneWidget);
    expect(find.textContaining('Alex Owner'), findsOneWidget);
  });

  testWidgets('shows a friendly error when the RPC fails', (tester) async {
    final repository = FakeAuthRepository(
      initialRestore: const AuthNeedsOnboarding(email: 'owner@gym.test'),
    );
    repository.createOrganizationError = const SupabaseFailure(
      message: 'Could not create your gym. Please try again.',
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(appWith(repository));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Gym / organization name'),
      'FitZone',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Owner full name'),
      'Alex Owner',
    );

    await tester.tap(find.text('Create gym'));
    await tester.pumpAndSettle();

    expect(find.text('Could not create your gym. Please try again.'), findsOneWidget);
    expect(find.text('Create your gym'), findsOneWidget);
  });
}
