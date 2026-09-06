import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';

void main() {
  final start = DateTime(2026, 9, 6);
  final end = DateTime(2026, 12, 6);

  Subscription makeSubscription({
    SubscriptionStatus status = SubscriptionStatus.active,
    DateTime? endDate,
  }) {
    return Subscription(
      id: 'sub-1',
      organizationId: 'org-1',
      memberId: 'member-1',
      planId: 'plan-1',
      startDate: start,
      endDate: endDate ?? end,
      status: status,
    );
  }

  // ---------------------------------------------------------------------------
  // Status enum mapping
  // ---------------------------------------------------------------------------
  group('SubscriptionStatusX.fromWireName', () {
    test('maps known database strings to statuses', () {
      expect(SubscriptionStatusX.fromWireName('active'), SubscriptionStatus.active);
      expect(
        SubscriptionStatusX.fromWireName('expired'),
        SubscriptionStatus.expired,
      );
      expect(
        SubscriptionStatusX.fromWireName('frozen'),
        SubscriptionStatus.frozen,
      );
      expect(
        SubscriptionStatusX.fromWireName('cancelled'),
        SubscriptionStatus.cancelled,
      );
    });

    test('returns null for unknown or missing statuses (safe failure)', () {
      expect(SubscriptionStatusX.fromWireName('paused'), isNull);
      expect(SubscriptionStatusX.fromWireName(''), isNull);
      expect(SubscriptionStatusX.fromWireName(null), isNull);
    });

    test('labels are human-readable', () {
      expect(SubscriptionStatus.active.label, 'Active');
      expect(SubscriptionStatus.expired.label, 'Expired');
      expect(SubscriptionStatus.frozen.label, 'Frozen');
      expect(SubscriptionStatus.cancelled.label, 'Cancelled');
    });

    test('isActive and isTerminal helpers reflect membership', () {
      expect(SubscriptionStatus.active.isActive, isTrue);
      expect(SubscriptionStatus.expired.isActive, isFalse);
      expect(SubscriptionStatus.expired.isTerminal, isTrue);
      expect(SubscriptionStatus.cancelled.isTerminal, isTrue);
      expect(SubscriptionStatus.frozen.isTerminal, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // remainingDays
  // ---------------------------------------------------------------------------
  group('Subscription.remainingDays', () {
    test('counts whole calendar days from the injected now', () {
      final subscription = makeSubscription();
      expect(
        subscription.remainingDays(now: DateTime(2026, 9, 6)),
        91,
      );
      expect(
        subscription.remainingDays(now: DateTime(2026, 9, 7)),
        90,
      );
      expect(
        subscription.remainingDays(now: DateTime(2026, 12, 6)),
        0,
      );
    });

    test('clamps to zero once the period has ended', () {
      final subscription = makeSubscription();
      expect(
        subscription.remainingDays(now: DateTime(2027, 1, 1)),
        0,
      );
    });

    test('returns null when there is no end date', () {
      final subscription = Subscription(
        id: 'sub-1',
        organizationId: 'org-1',
        memberId: 'member-1',
        planId: 'plan-1',
        startDate: start,
        endDate: null,
        status: SubscriptionStatus.active,
      );
      expect(subscription.remainingDays(), isNull);
    });

    test('defaults to the device clock when now is omitted', () {
      final subscription = makeSubscription(
        endDate: DateTime.now().add(const Duration(days: 5)),
      );
      expect(subscription.remainingDays(), 5);
    });
  });

  // ---------------------------------------------------------------------------
  // isValid
  // ---------------------------------------------------------------------------
  group('Subscription.isValid', () {
    test('active subscription inside its period is valid', () {
      expect(
        makeSubscription().isValid(now: DateTime(2026, 9, 6)),
        isTrue,
      );
    });

    test('active subscription past its end date is invalid', () {
      expect(
        makeSubscription().isValid(now: DateTime(2027, 1, 1)),
        isFalse,
      );
    });

    test('non-active statuses are never valid', () {
      expect(
        makeSubscription(status: SubscriptionStatus.frozen).isValid(),
        isFalse,
      );
      expect(
        makeSubscription(status: SubscriptionStatus.cancelled).isValid(),
        isFalse,
      );
      expect(
        makeSubscription(status: SubscriptionStatus.expired).isValid(),
        isFalse,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // isExpiringSoon
  // ---------------------------------------------------------------------------
  group('Subscription.isExpiringSoon', () {
    test('true when within 7 days of the end date', () {
      final subscription = makeSubscription();
      expect(subscription.isExpiringSoon(now: DateTime(2026, 12, 1)), isTrue);
      expect(subscription.isExpiringSoon(now: DateTime(2026, 11, 30)), isTrue);
    });

    test('false when far from the end date', () {
      final subscription = makeSubscription();
      expect(subscription.isExpiringSoon(now: DateTime(2026, 9, 6)), isFalse);
    });

    test('false for non-active subscriptions', () {
      final subscription = makeSubscription(status: SubscriptionStatus.frozen);
      expect(subscription.isExpiringSoon(now: DateTime(2026, 12, 1)), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // displayStatus
  // ---------------------------------------------------------------------------
  group('Subscription.displayStatus', () {
    test('active subscription past its end date displays as expired', () {
      // End date deliberately in the past relative to the device clock.
      final subscription = Subscription(
        id: 'sub-1',
        organizationId: 'org-1',
        memberId: 'member-1',
        planId: 'plan-1',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 3, 1),
        status: SubscriptionStatus.active,
      );
      expect(subscription.displayStatus, SubscriptionStatus.expired);
    });

    test('active subscription inside its period stays active', () {
      final subscription = Subscription(
        id: 'sub-1',
        organizationId: 'org-1',
        memberId: 'member-1',
        planId: 'plan-1',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime.now().add(const Duration(days: 90)),
        status: SubscriptionStatus.active,
      );
      expect(subscription.displayStatus, SubscriptionStatus.active);
    });

    test('frozen and cancelled statuses are shown as-is', () {
      expect(
        makeSubscription(status: SubscriptionStatus.frozen).displayStatus,
        SubscriptionStatus.frozen,
      );
      expect(
        makeSubscription(status: SubscriptionStatus.cancelled).displayStatus,
        SubscriptionStatus.cancelled,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Value semantics
  // ---------------------------------------------------------------------------
  group('Subscription value semantics', () {
    test('supports value equality', () {
      final a = makeSubscription();
      final b = makeSubscription();
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('supports copyWith', () {
      final a = makeSubscription();
      final b = a.copyWith(status: SubscriptionStatus.frozen);
      expect(b.status, SubscriptionStatus.frozen);
      expect(b.id, a.id);
    });
  });
}
