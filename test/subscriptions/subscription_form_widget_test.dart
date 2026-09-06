import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gym_management_app/features/subscriptions/presentation/providers/subscriptions_provider.dart';
import 'package:gym_management_app/features/subscriptions/presentation/screens/subscription_form_screen.dart';

import '../helpers/fake_subscription_repository.dart';

Widget formApp(FakeSubscriptionRepository repository) {
  return ProviderScope(
    overrides: [subscriptionRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(
      home: SubscriptionFormScreen(memberId: 'member-1'),
    ),
  );
}

void main() {
  final plan = FakeSubscriptionRepository.makeTestPlan();

  testWidgets('shows validation error when no plan is selected', (
    tester,
  ) async {
    final repository = FakeSubscriptionRepository(plans: [plan]);
    await tester.pumpWidget(formApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create Subscription'));
    await tester.pumpAndSettle();

    expect(find.text('Please select a plan.'), findsOneWidget);
  });

  testWidgets('shows an empty state when no plans are available', (
    tester,
  ) async {
    final repository = FakeSubscriptionRepository(plans: const []);
    await tester.pumpWidget(formApp(repository));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('No subscription plans are available yet.'),
      findsOneWidget,
    );
  });

  testWidgets('shows a summary when a plan is selected', (tester) async {
    final repository = FakeSubscriptionRepository(plans: [plan]);
    await tester.pumpWidget(formApp(repository));
    await tester.pumpAndSettle();

    // Open the plan dropdown and pick the only plan.
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1 month — Monthly (500)').last);
    await tester.pumpAndSettle();

    expect(find.text('Summary'), findsOneWidget);
    expect(find.text('Duration'), findsOneWidget);
  });
}
