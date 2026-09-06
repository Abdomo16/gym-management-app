import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:gym_management_app/features/subscriptions/domain/usecases/cancel_subscription.dart';
import 'package:gym_management_app/features/subscriptions/domain/usecases/create_subscription.dart';
import 'package:gym_management_app/features/subscriptions/domain/usecases/freeze_subscription.dart';
import 'package:gym_management_app/features/subscriptions/domain/usecases/get_subscription_history.dart';
import 'package:gym_management_app/features/subscriptions/domain/usecases/get_subscription_plans.dart';
import 'package:gym_management_app/features/subscriptions/domain/usecases/renew_subscription.dart';

import '../helpers/fake_subscription_repository.dart';

void main() {
  final monthly = FakeSubscriptionRepository.makeTestPlan();
  final quarterly = FakeSubscriptionRepository.makeTestPlan(
    id: 'plan-2',
    name: '3 Months',
    durationDays: 91,
    price: 1200,
  );

  group('GetSubscriptionPlans', () {
    test('returns active plans', () async {
      final repo = FakeSubscriptionRepository(plans: [monthly, quarterly]);
      final plans = await GetSubscriptionPlans(repo)();
      expect(plans, hasLength(2));
      expect(plans.first.name, 'Monthly');
    });

    test('excludes inactive plans when activeOnly is true', () async {
      final inactive = FakeSubscriptionRepository.makeTestPlan(
        id: 'plan-3',
        name: 'Retired',
        isActive: false,
      );
      final repo = FakeSubscriptionRepository(
        plans: [monthly, inactive],
      );
      final plans = await GetSubscriptionPlans(repo)();
      expect(plans, hasLength(1));
      expect(plans.first.id, 'plan-1');
    });

    test('propagates failures', () async {
      final repo = FakeSubscriptionRepository(throwOnPlans: true);
      await expectLater(
        GetSubscriptionPlans(repo)(),
        throwsA(isA<SupabaseFailure>()),
      );
    });
  });

  group('GetSubscriptionHistory', () {
    test('returns the member\'s subscriptions newest first', () async {
      final existing = FakeSubscriptionRepository.makeTestSubscription();
      final repo = FakeSubscriptionRepository(
        subscriptions: [existing],
      );
      final history = await GetSubscriptionHistory(repo)('member-1');
      expect(history, hasLength(1));
      expect(history.first.id, 'sub-1');
    });

    test('returns only the requested member\'s records', () async {
      final other = FakeSubscriptionRepository.makeTestSubscription(
        id: 'sub-9',
        memberId: 'member-9',
      );
      final repo = FakeSubscriptionRepository(subscriptions: [other]);
      final history = await GetSubscriptionHistory(repo)('member-1');
      expect(history, isEmpty);
    });

    test('propagates failures', () async {
      final repo = FakeSubscriptionRepository(throwOnHistory: true);
      await expectLater(
        GetSubscriptionHistory(repo)('member-1'),
        throwsA(isA<SupabaseFailure>()),
      );
    });
  });

  group('CreateSubscription', () {
    test('creates a subscription and returns the computed period', () async {
      final repo = FakeSubscriptionRepository(plans: [monthly]);
      final subscription = await CreateSubscription(repo)(
        organizationId: 'org-1',
        memberId: 'member-1',
        planId: 'plan-1',
        startDate: DateTime(2026, 9, 6),
      );
      expect(subscription.memberId, 'member-1');
      expect(subscription.planId, 'plan-1');
      expect(subscription.status, SubscriptionStatus.active);
      expect(subscription.endDate, DateTime(2026, 10, 6));
    });

    test('propagates failures', () async {
      final repo = FakeSubscriptionRepository(throwOnCreate: true);
      await expectLater(
        CreateSubscription(repo)(
          organizationId: 'org-1',
          memberId: 'member-1',
          planId: 'plan-1',
        ),
        throwsA(isA<SupabaseFailure>()),
      );
    });
  });

  group('RenewSubscription', () {
    test('creates a new record without overwriting history', () async {
      final existing = FakeSubscriptionRepository.makeTestSubscription();
      final repo = FakeSubscriptionRepository(
        plans: [monthly],
        subscriptions: [existing],
      );
      final renewed = await RenewSubscription(repo)(
        organizationId: 'org-1',
        memberId: 'member-1',
        planId: 'plan-1',
        startDate: DateTime(2026, 12, 6),
      );
      expect(renewed.id, isNot(existing.id));

      final history = await GetSubscriptionHistory(repo)('member-1');
      expect(history, hasLength(2));
    });

    test('propagates failures', () async {
      final repo = FakeSubscriptionRepository(throwOnCreate: true);
      await expectLater(
        RenewSubscription(repo)(
          organizationId: 'org-1',
          memberId: 'member-1',
          planId: 'plan-1',
        ),
        throwsA(isA<SupabaseFailure>()),
      );
    });
  });

  group('CancelSubscription', () {
    test('marks the subscription as cancelled', () async {
      final existing = FakeSubscriptionRepository.makeTestSubscription();
      final repo = FakeSubscriptionRepository(subscriptions: [existing]);
      final result = await CancelSubscription(repo)('sub-1');
      expect(result.status, SubscriptionStatus.cancelled);
    });

    test('propagates failures', () async {
      final repo = FakeSubscriptionRepository(throwOnUpdate: true);
      await expectLater(
        CancelSubscription(repo)('sub-1'),
        throwsA(isA<SupabaseFailure>()),
      );
    });
  });

  group('FreezeSubscription', () {
    test('marks the subscription as frozen', () async {
      final existing = FakeSubscriptionRepository.makeTestSubscription();
      final repo = FakeSubscriptionRepository(subscriptions: [existing]);
      final result = await FreezeSubscription(repo)('sub-1');
      expect(result.status, SubscriptionStatus.frozen);
    });

    test('propagates failures', () async {
      final repo = FakeSubscriptionRepository(throwOnUpdate: true);
      await expectLater(
        FreezeSubscription(repo)('sub-1'),
        throwsA(isA<SupabaseFailure>()),
      );
    });
  });
}
