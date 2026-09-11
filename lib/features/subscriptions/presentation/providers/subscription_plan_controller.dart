import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/features/subscriptions/domain/usecases/create_subscription_plan.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/subscription_plans_provider.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/subscriptions_provider.dart';

/// Whether a plan mutation (create/delete) is in flight.
enum PlanActionStatus { idle, busy }

/// Performs subscription-plan mutations and keeps the plans provider in
/// sync. The database's RLS policy remains the security boundary for who
/// may write; failures propagate to the caller as typed [AppFailure]s.
class PlanController extends Notifier<PlanActionStatus> {
  @override
  PlanActionStatus build() => PlanActionStatus.idle;

  Future<void> createPlan({
    required String organizationId,
    required String name,
    required int durationDays,
    required double price,
    String? description,
  }) {
    return _run(
      () => CreateSubscriptionPlan(ref.read(subscriptionRepositoryProvider))(
        organizationId: organizationId,
        name: name,
        durationDays: durationDays,
        price: price,
        description: description,
      ),
    );
  }

  Future<void> deactivatePlan(String planId) {
    return _run(
      () => DeactivateSubscriptionPlan(
        ref.read(subscriptionRepositoryProvider),
      )(planId),
    );
  }

  /// Runs [action] under the busy flag, refreshing the plans provider
  /// after a successful mutation.
  Future<void> _run(Future<void> Function() action) async {
    state = PlanActionStatus.busy;
    try {
      await action();
      ref.invalidate(subscriptionPlansProvider);
    } finally {
      state = PlanActionStatus.idle;
    }
  }
}

/// Tracks whether a plan mutation is currently running.
final planControllerProvider =
    NotifierProvider<PlanController, PlanActionStatus>(PlanController.new);
