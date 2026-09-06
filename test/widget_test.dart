import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gym_management_app/app/app.dart';
import 'package:gym_management_app/core/widgets/app_text_field.dart';
import 'package:gym_management_app/features/auth/domain/entities/app_user.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_providers.dart';

import 'helpers/fake_auth_repository.dart';

Widget _appWith(FakeAuthRepository repository) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
    child: const GymApp(),
  );
}

void main() {
  testWidgets('shows the sign-in screen when unauthenticated', (tester) async {
    final repository = FakeAuthRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(_appWith(repository));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byType(AppTextField), findsNWidgets(2));
  });

  testWidgets('shows the dashboard when authenticated', (tester) async {
    final repository = FakeAuthRepository(
      initialUser: const AppUser(
        id: 'user-1',
        email: 'owner@gym.test',
        displayName: 'Alex Owner',
        role: UserRole.owner,
      ),
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(_appWith(repository));
    await tester.pumpAndSettle();

    expect(find.text('Recent check-ins'), findsOneWidget);
    expect(find.textContaining('Alex Owner'), findsOneWidget);
  });

  testWidgets('signs in with credentials and lands on the dashboard', (
    tester,
  ) async {
    final repository = FakeAuthRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(_appWith(repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'owner@gym.test');
    await tester.enterText(find.byType(TextField).at(1), 'correct-password');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Recent check-ins'), findsOneWidget);
  });

  testWidgets('shows an error banner on failed sign-in', (tester) async {
    final repository = FakeAuthRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(_appWith(repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'owner@gym.test');
    await tester.enterText(find.byType(TextField).at(1), 'wrong-password');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid login credentials.'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
