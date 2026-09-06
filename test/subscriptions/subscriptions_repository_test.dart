import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';

import '../helpers/fake_subscription_repository.dart';

void main() {
  group('SubscriptionRepository – getPlans', () {
    test('returns active plans only by default', () async {
      final active = FakeSubscriptionRepository.makeTestPlan();
      final retired = FakeSubscriptionRepository.makeTestPlan(
        id: 'plan-9',
        name: 'Retired',
        isActive: false,
      );
      final repo = FakeSubscriptionRepository(plans: [active, retired]);

      final plans = await repo.getPlans();
      expect(plans, hasLength(1));
      expect(plans.single.id, 'plan-1');

      final all = await repo.getPlans(activeOnly: false);
      expect(all, hasLength(2));
    });

    test('propagates failures', () async {
      final repo = FakeSubscriptionRepository(throwOnPlans: true);
      await expectLater(
        repo.getPlans(),
        throwsA(isA<SupabaseFailure>()),
      );
    });
  });

  group('SubscriptionRepository – getMemberSubscriptions', () {
    test('returns only the requested member\'s records', () async {
      final mine = FakeSubscriptionRepository.makeTestSubscription();
      final theirs = FakeSubscriptionRepository.makeTestSubscription(
        id: 'sub-9',
        memberId: 'member-9',
      );
      final repo = FakeSubscriptionRepository(
        subscriptions: [mine, theirs],
      );

      final history = await repo.getMemberSubscriptions('member-1');
      expect(history, hasLength(1));
      expect(history.single.id, 'sub-1');
    });

    test('propagates failures', () async {
      final repo = FakeSubscriptionRepository(throwOnHistory: true);
      await expectLater(
        repo.getMemberSubscriptions('member-1'),
        throwsA(isA<SupabaseFailure>()),
      );
    });
  });

  group('SubscriptionRepository – createSubscription', () {
    test('computes the end date from the plan duration', () async {
      final plan = FakeSubscriptionRepository.makeTestPlan(
        durationDays: 91,
      );
      final repo = FakeSubscriptionRepository(plans: [plan]);

      final subscription = await repo.createSubscription(
        organizationId: 'org-1',
        memberId: 'member-1',
        planId: 'plan-1',
        startDate: DateTime(2026, 9, 6),
      );

      expect(subscription.endDate, DateTime(2026, 12, 6));
      expect(subscription.status, SubscriptionStatus.active);
    });

    test('appends to history without overwriting previous records', () async {
      final plan = FakeSubscriptionRepository.makeTestPlan();
      final existing = FakeSubscriptionRepository.makeTestSubscription();
      final repo = FakeSubscriptionRepository(
        plans: [plan],
        subscriptions: [existing],
      );

      await repo.createSubscription(
        organizationId: 'org-1',
        memberId: 'member-1',
        planId: 'plan-1',
        startDate: DateTime(2026, 12, 6),
      );

      final history = await repo.getMemberSubscriptions('member-1');
      expect(history, hasLength(2));
    });

    test('propagates failures', () async {
      final repo = FakeSubscriptionRepository(throwOnCreate: true);
      await expectLater(
        repo.createSubscription(
          organizationId: 'org-1',
          memberId: 'member-1',
          planId: 'plan-1',
        ),
        throwsA(isA<SupabaseFailure>()),
      );
    });
  });

  group('SubscriptionRepository – updateSubscriptionStatus', () {
    test('applies the requested status to the record', () async {
      final existing = FakeSubscriptionRepository.makeTestSubscription();
      final repo = FakeSubscriptionRepository(subscriptions: [existing]);

      final frozen = await repo.updateSubscriptionStatus(
        id: 'sub-1',
        status: SubscriptionStatus.frozen,
      );
      expect(frozen.status, SubscriptionStatus.frozen);

      // The record remains in history — never deleted.
      final history = await repo.getMemberSubscriptions('member-1');
      expect(history, hasLength(1));
      expect(history.single.status, SubscriptionStatus.frozen);
    });

    test('propagates failures', () async {
      final repo = FakeSubscriptionRepository(throwOnUpdate: true);
      await expectLater(
        repo.updateSubscriptionStatus(
          id: 'sub-1',
          status: SubscriptionStatus.cancelled,
        ),
        throwsA(isA<SupabaseFailure>()),
      );
    });
  });
}
