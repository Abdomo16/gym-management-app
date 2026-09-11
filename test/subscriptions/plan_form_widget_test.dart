import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gym_management_app/features/auth/domain/entities/organization_context.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/subscriptions_provider.dart';
import 'package:gym_management_app/features/subscriptions/presentation/screens/plan_form_screen.dart';

import '../helpers/auth_fixtures.dart';
import '../helpers/fake_subscription_repository.dart';

Widget formApp(FakeSubscriptionRepository repository) {
  final profile = makeAppUser().profile;
  return ProviderScope(
    overrides: [
      subscriptionRepositoryProvider.overrideWithValue(repository),
      organizationContextProvider.overrideWithValue(
        OrganizationContext(
          organizationId: 'org-1',
          role: profile.role,
          profile: profile,
        ),
      ),
    ],
    child: const MaterialApp(home: PlanFormScreen()),
  );
}

void main() {
  testWidgets('shows validation errors for an empty form', (tester) async {
    await tester.pumpWidget(formApp(FakeSubscriptionRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create Plan'));
    await tester.pumpAndSettle();

    expect(find.text('Name is required.'), findsOneWidget);
    expect(find.text('Price is required.'), findsOneWidget);
  });

  testWidgets('creates a plan and closes the form on success', (tester) async {
    final repository = FakeSubscriptionRepository();
    await tester.pumpWidget(formApp(repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Monthly');
    await tester.enterText(find.byType(TextFormField).at(1), '500');
    await tester.tap(find.text('Create Plan'));
    await tester.pumpAndSettle();

    expect(repository.storedPlans, hasLength(1));
    expect(repository.storedPlans.single.name, 'Monthly');
    expect(repository.storedPlans.single.durationDays, 30);
    expect(repository.storedPlans.single.price, 500);
    // The form pops itself on success (Navigator.pop).
    expect(find.byType(PlanFormScreen), findsNothing);
  });

  testWidgets('shows a server error when plan creation fails', (tester) async {
    await tester.pumpWidget(
      formApp(FakeSubscriptionRepository(throwOnPlanWrite: true)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Monthly');
    await tester.enterText(find.byType(TextFormField).at(1), '500');
    await tester.tap(find.text('Create Plan'));
    await tester.pumpAndSettle();

    expect(find.text('Simulated plan write error.'), findsOneWidget);
    // The form stays open so the user can retry.
    expect(find.byType(PlanFormScreen), findsOneWidget);
  });
}
