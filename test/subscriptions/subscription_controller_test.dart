import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/subscription_controller.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/subscriptions_provider.dart';

import '../helpers/fake_subscription_repository.dart';

ProviderContainer makeContainer(FakeSubscriptionRepository repo) {
  final container = ProviderContainer(
    overrides: [subscriptionRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  final plan = FakeSubscriptionRepository.makeTestPlan();

  group('SubscriptionController – initial state', () {
    test('initial state is idle', () {
      final container = makeContainer(FakeSubscriptionRepository());
      expect(
        container.read(subscriptionControllerProvider),
        SubscriptionActionStatus.idle,
      );
    });
  });

  group('SubscriptionController.createSubscription', () {
    test('returns the created subscription on success', () async {
      final container = makeContainer(
        FakeSubscriptionRepository(plans: [plan]),
      );
      final result = await container
          .read(subscriptionControllerProvider.notifier)
          .createSubscription(
            organizationId: 'org-1',
            memberId: 'member-1',
            planId: 'plan-1',
            startDate: DateTime(2026, 9, 6),
          );
      expect(result, isA<Subscription>());
      expect(result.memberId, 'member-1');
      expect(result.endDate, DateTime(2026, 10, 6));
    });

    test('state returns to idle after success', () async {
      final container = makeContainer(
        FakeSubscriptionRepository(plans: [plan]),
      );
      await container
          .read(subscriptionControllerProvider.notifier)
          .createSubscription(
            organizationId: 'org-1',
            memberId: 'member-1',
            planId: 'plan-1',
          );
      expect(
        container.read(subscriptionControllerProvider),
        SubscriptionActionStatus.idle,
      );
    });

    test('state returns to idle and failure propagates after error', () async {
      final container = makeContainer(
        FakeSubscriptionRepository(throwOnCreate: true),
      );
      await expectLater(
        container.read(subscriptionControllerProvider.notifier)
            .createSubscription(
              organizationId: 'org-1',
              memberId: 'member-1',
              planId: 'plan-1',
            ),
        throwsA(isA<SupabaseFailure>()),
      );
      expect(
        container.read(subscriptionControllerProvider),
        SubscriptionActionStatus.idle,
      );
    });
  });

  group('SubscriptionController.renewSubscription', () {
    test('creates a new record and keeps the old one', () async {
      final existing = FakeSubscriptionRepository.makeTestSubscription();
      final container = makeContainer(
        FakeSubscriptionRepository(plans: [plan], subscriptions: [existing]),
      );
      final result = await container
          .read(subscriptionControllerProvider.notifier)
          .renewSubscription(
            organizationId: 'org-1',
            memberId: 'member-1',
            planId: 'plan-1',
            startDate: DateTime(2026, 12, 6),
          );
      expect(result.id, isNot(existing.id));

      // History is refetched after a successful mutation.
      final history = await container
          .read(subscriptionRepositoryProvider)
          .getMemberSubscriptions('member-1');
      expect(history, hasLength(2));
    });

    test('state returns to idle after renewal failure', () async {
      final container = makeContainer(
        FakeSubscriptionRepository(throwOnCreate: true),
      );
      await expectLater(
        container.read(subscriptionControllerProvider.notifier)
            .renewSubscription(
              organizationId: 'org-1',
              memberId: 'member-1',
              planId: 'plan-1',
            ),
        throwsA(isA<AppFailure>()),
      );
      expect(
        container.read(subscriptionControllerProvider),
        SubscriptionActionStatus.idle,
      );
    });
  });

  group('SubscriptionController.freezeSubscription', () {
    test('freezes the subscription', () async {
      final existing = FakeSubscriptionRepository.makeTestSubscription();
      final container = makeContainer(
        FakeSubscriptionRepository(subscriptions: [existing]),
      );
      final result = await container
          .read(subscriptionControllerProvider.notifier)
          .freezeSubscription(
            memberId: 'member-1',
            subscriptionId: 'sub-1',
          );
      expect(result.status, SubscriptionStatus.frozen);
    });

    test('state returns to idle after failure', () async {
      final container = makeContainer(
        FakeSubscriptionRepository(throwOnUpdate: true),
      );
      await expectLater(
        container.read(subscriptionControllerProvider.notifier)
            .freezeSubscription(memberId: 'member-1', subscriptionId: 'sub-1'),
        throwsA(isA<SupabaseFailure>()),
      );
      expect(
        container.read(subscriptionControllerProvider),
        SubscriptionActionStatus.idle,
      );
    });
  });

  group('SubscriptionController.cancelSubscription', () {
    test('cancels the subscription', () async {
      final existing = FakeSubscriptionRepository.makeTestSubscription();
      final container = makeContainer(
        FakeSubscriptionRepository(subscriptions: [existing]),
      );
      final result = await container
          .read(subscriptionControllerProvider.notifier)
          .cancelSubscription(
            memberId: 'member-1',
            subscriptionId: 'sub-1',
          );
      expect(result.status, SubscriptionStatus.cancelled);
    });

    test('state returns to idle after failure', () async {
      final container = makeContainer(
        FakeSubscriptionRepository(throwOnUpdate: true),
      );
      await expectLater(
        container.read(subscriptionControllerProvider.notifier)
            .cancelSubscription(
              memberId: 'member-1',
              subscriptionId: 'sub-1',
            ),
        throwsA(isA<SupabaseFailure>()),
      );
      expect(
        container.read(subscriptionControllerProvider),
        SubscriptionActionStatus.idle,
      );
    });
  });
}
