import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription_plan.dart';

void main() {
  SubscriptionPlan makePlan({
    String id = 'plan-1',
    String organizationId = 'org-1',
    String name = 'Monthly',
    int? durationDays = 30,
    double? price = 500,
    bool isActive = true,
  }) {
    return SubscriptionPlan(
      id: id,
      organizationId: organizationId,
      name: name,
      durationDays: durationDays,
      price: price,
      isActive: isActive,
    );
  }

  group('SubscriptionPlan.durationLabel', () {
    test('30 days renders as "1 month"', () {
      expect(makePlan(durationDays: 30).durationLabel, '1 month');
    });

    test('90 days renders as "3 months"', () {
      expect(makePlan(durationDays: 90).durationLabel, '3 months');
    });

    test('7 days renders as "1 week"', () {
      expect(makePlan(durationDays: 7).durationLabel, '1 week');
    });

    test('14 days renders as "2 weeks"', () {
      expect(makePlan(durationDays: 14).durationLabel, '2 weeks');
    });

    test('1 day renders as "1 day"', () {
      expect(makePlan(durationDays: 1).durationLabel, '1 day');
    });

    test('arbitrary durations render as N days', () {
      expect(makePlan(durationDays: 45).durationLabel, '45 days');
    });

    test('missing duration renders a fallback label', () {
      expect(makePlan(durationDays: null).durationLabel, 'Duration not set');
    });
  });

  group('SubscriptionPlan.priceLabel', () {
    test('whole prices render without decimals', () {
      expect(makePlan(price: 500).priceLabel, '500');
    });

    test('fractional prices render with two decimals', () {
      expect(makePlan(price: 499.5).priceLabel, '499.50');
    });

    test('null price renders null', () {
      expect(makePlan(price: null).priceLabel, isNull);
    });
  });

  group('SubscriptionPlan value semantics', () {
    test('supports value equality', () {
      expect(makePlan(), makePlan());
    });

    test('supports copyWith', () {
      final plan = makePlan();
      final updated = plan.copyWith(isActive: false);
      expect(updated.isActive, isFalse);
      expect(updated.id, plan.id);
    });

    test('defaults to active', () {
      expect(makePlan().isActive, isTrue);
    });
  });
}
