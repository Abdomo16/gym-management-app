import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/subscriptions/domain/usecases/create_subscription_plan.dart';

import '../helpers/fake_subscription_repository.dart';

void main() {
  group('CreateSubscriptionPlan', () {
    test('creates a plan with trimmed name and computed duration', () async {
      final repository = FakeSubscriptionRepository();
      final useCase = CreateSubscriptionPlan(repository);

      final plan = await useCase(
        organizationId: 'org-1',
        name: '  Monthly  ',
        durationDays: 30,
        price: 500,
      );

      expect(plan.name, 'Monthly');
      expect(plan.durationDays, 30);
      expect(plan.price, 500);
      expect(plan.organizationId, 'org-1');
      expect(repository.storedPlans, hasLength(1));
    });

    test('rejects an empty name', () {
      final repository = FakeSubscriptionRepository();

      expect(
        () => CreateSubscriptionPlan(repository)(
          organizationId: 'org-1',
          name: '   ',
          durationDays: 30,
          price: 500,
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('rejects a non-positive duration', () {
      final repository = FakeSubscriptionRepository();

      expect(
        () => CreateSubscriptionPlan(repository)(
          organizationId: 'org-1',
          name: 'Monthly',
          durationDays: 0,
          price: 500,
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('rejects a negative price', () {
      final repository = FakeSubscriptionRepository();

      expect(
        () => CreateSubscriptionPlan(repository)(
          organizationId: 'org-1',
          name: 'Monthly',
          durationDays: 30,
          price: -1,
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('surfaces repository failures as typed failures', () async {
      final repository = FakeSubscriptionRepository(throwOnPlanWrite: true);

      await expectLater(
        CreateSubscriptionPlan(repository)(
          organizationId: 'org-1',
          name: 'Monthly',
          durationDays: 30,
          price: 500,
        ),
        throwsA(isA<SupabaseFailure>()),
      );
    });
  });

  group('DeactivateSubscriptionPlan', () {
    test('deactivates the plan in the repository', () async {
      final repository = FakeSubscriptionRepository(
        plans: [FakeSubscriptionRepository.makeTestPlan()],
      );
      final useCase = DeactivateSubscriptionPlan(repository);

      await useCase('plan-1');

      expect(repository.storedPlans.single.isActive, isFalse);
    });
  });
}
