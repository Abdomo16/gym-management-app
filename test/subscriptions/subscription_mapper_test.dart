import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/subscriptions/data/mappers/subscription_mapper.dart';
import 'package:gym_management_app/features/subscriptions/data/mappers/subscription_plan_mapper.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';

void main() {
  // ---------------------------------------------------------------------------
  // SubscriptionMapper
  // ---------------------------------------------------------------------------
  group('SubscriptionMapper.fromMap', () {
    final base = <String, dynamic>{
      'id': 'sub-1',
      'organization_id': 'org-1',
      'member_id': 'member-1',
      'plan_id': 'plan-1',
      'start_date': '2026-09-06T00:00:00.000Z',
      'end_date': '2026-12-06T00:00:00.000Z',
      'status': 'active',
      'created_at': '2026-09-06T10:00:00.000Z',
      'updated_at': '2026-09-06T10:00:00.000Z',
    };

    test('maps a full row into the entity', () {
      final subscription = SubscriptionMapper.fromMap(base);
      expect(subscription.id, 'sub-1');
      expect(subscription.organizationId, 'org-1');
      expect(subscription.memberId, 'member-1');
      expect(subscription.planId, 'plan-1');
      expect(subscription.startDate, DateTime.parse('2026-09-06T00:00:00.000Z'));
      expect(subscription.endDate, DateTime.parse('2026-12-06T00:00:00.000Z'));
      expect(subscription.status, SubscriptionStatus.active);
      expect(subscription.createdAt, isNotNull);
      expect(subscription.updatedAt, isNotNull);
    });

    test('maps all known status strings', () {
      for (final status in SubscriptionStatus.values) {
        final subscription = SubscriptionMapper.fromMap({
          ...base,
          'status': status.name,
        });
        expect(subscription.status, status);
      }
    });

    test('tolerates a null end date (period not yet computed)', () {
      final subscription = SubscriptionMapper.fromMap({
        ...base,
        'end_date': null,
      });
      expect(subscription.endDate, isNull);
    });

    test('throws ValidationFailure for an unknown status', () {
      expect(
        () => SubscriptionMapper.fromMap({...base, 'status': 'paused'}),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('throws ValidationFailure for a null status', () {
      expect(
        () => SubscriptionMapper.fromMap({...base, 'status': null}),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('throws ValidationFailure when the start date is missing', () {
      expect(
        () => SubscriptionMapper.fromMap({...base, 'start_date': null}),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // SubscriptionPlanMapper
  // ---------------------------------------------------------------------------
  group('SubscriptionPlanMapper.fromMap', () {
    final base = <String, dynamic>{
      'id': 'plan-1',
      'organization_id': 'org-1',
      'name': '3 Months',
      'description': 'Full access for three months',
      'duration_days': 91,
      'price': 1200,
      'is_active': true,
      'created_at': '2026-01-01T00:00:00.000Z',
      'updated_at': '2026-01-01T00:00:00.000Z',
    };

    test('maps a full row into the entity', () {
      final plan = SubscriptionPlanMapper.fromMap(base);
      expect(plan.id, 'plan-1');
      expect(plan.organizationId, 'org-1');
      expect(plan.name, '3 Months');
      expect(plan.description, 'Full access for three months');
      expect(plan.durationDays, 91);
      expect(plan.price, 1200);
      expect(plan.isActive, isTrue);
    });

    test('treats numeric price values as doubles', () {
      final plan = SubscriptionPlanMapper.fromMap({...base, 'price': 499.5});
      expect(plan.price, 499.5);
    });

    test('tolerates a null price and description', () {
      final plan = SubscriptionPlanMapper.fromMap({
        ...base,
        'price': null,
        'description': null,
      });
      expect(plan.price, isNull);
      expect(plan.description, isNull);
    });

    test('defaults is_active to true when absent', () {
      final plan = SubscriptionPlanMapper.fromMap({...base, 'is_active': null});
      expect(plan.isActive, isTrue);
    });

    test('throws ValidationFailure when the duration is missing', () {
      expect(
        () => SubscriptionPlanMapper.fromMap({...base, 'duration_days': null}),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });
}
