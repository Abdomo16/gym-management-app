import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/subscriptions_provider.dart';
import 'package:gym_management_app/features/subscriptions/presentation/screens/subscriptions_screen.dart';

import '../helpers/fake_subscription_repository.dart';

Widget screenApp(
  FakeSubscriptionRepository repository, {
  UserRole role = UserRole.owner,
}) {
  return ProviderScope(
    overrides: [
      subscriptionRepositoryProvider.overrideWithValue(repository),
      currentProfileProvider.overrideWithValue(
        UserProfile(
          id: 'user-1',
          organizationId: 'org-1',
          fullName: 'Alex Owner',
          role: role,
        ),
      ),
    ],
    child: const MaterialApp(home: SubscriptionsScreen()),
  );
}

void main() {
  testWidgets('shows an empty state with an add action for owners', (
    tester,
  ) async {
    await tester.pumpWidget(screenApp(FakeSubscriptionRepository()));
    await tester.pumpAndSettle();

    expect(find.text('No plans yet'), findsOneWidget);
    expect(find.text('Add plan'), findsOneWidget);
  });

  testWidgets('lists plans sorted by duration with prices', (tester) async {
    final repository = FakeSubscriptionRepository(plans: [
      FakeSubscriptionRepository.makeTestPlan(
        id: 'plan-year',
        name: 'Yearly',
        durationDays: 360,
        price: 3000,
      ),
      FakeSubscriptionRepository.makeTestPlan(
        id: 'plan-month',
        name: 'Monthly',
        durationDays: 30,
        price: 500,
      ),
    ]);
    await tester.pumpWidget(screenApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('Yearly'), findsOneWidget);
    expect(find.text('500'), findsOneWidget);
    expect(find.text('3000'), findsOneWidget);
    // Sorted shortest first: Monthly appears above Yearly.
    expect(
      tester.getTopLeft(find.text('Monthly')).dy <
          tester.getTopLeft(find.text('Yearly')).dy,
      isTrue,
    );
    expect(find.text('Add plan'), findsOneWidget);
  });

  testWidgets('hides plan management for receptionists', (tester) async {
    final repository = FakeSubscriptionRepository(plans: [
      FakeSubscriptionRepository.makeTestPlan(),
    ]);
    await tester.pumpWidget(screenApp(repository, role: UserRole.receptionist));
    await tester.pumpAndSettle();

    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('Add plan'), findsNothing);
    expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
  });
}
