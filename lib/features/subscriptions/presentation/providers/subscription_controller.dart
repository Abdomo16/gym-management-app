import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:gym_management_app/features/subscriptions/domain/usecases/cancel_subscription.dart';
import 'package:gym_management_app/features/subscriptions/domain/usecases/create_subscription.dart';
import 'package:gym_management_app/features/subscriptions/domain/usecases/freeze_subscription.dart';
import 'package:gym_management_app/features/subscriptions/domain/usecases/renew_subscription.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/member_subscriptions_provider.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/subscriptions_provider.dart';

/// Whether a subscription mutation (create/renew/freeze/cancel) is in
/// flight.
enum SubscriptionActionStatus { idle, busy }

/// Performs subscription mutations and keeps related providers in sync.
///
/// Screens observe [status] to disable submit buttons and prevent duplicate
/// submissions; failures propagate to the caller as typed [AppFailure]s.
class SubscriptionController extends Notifier<SubscriptionActionStatus> {
  @override
  SubscriptionActionStatus build() => SubscriptionActionStatus.idle;

  Future<Subscription> createSubscription({
    required String organizationId,
    required String memberId,
    required String planId,
    DateTime? startDate,
  }) {
    return _run(
      memberId,
      () => CreateSubscription(ref.read(subscriptionRepositoryProvider))(
        organizationId: organizationId,
        memberId: memberId,
        planId: planId,
        startDate: startDate,
      ),
    );
  }

  Future<Subscription> renewSubscription({
    required String organizationId,
    required String memberId,
    required String planId,
    DateTime? startDate,
  }) {
    return _run(
      memberId,
      () => RenewSubscription(ref.read(subscriptionRepositoryProvider))(
        organizationId: organizationId,
        memberId: memberId,
        planId: planId,
        startDate: startDate,
      ),
    );
  }

  Future<Subscription> cancelSubscription({
    required String memberId,
    required String subscriptionId,
  }) {
    return _run(
      memberId,
      () => CancelSubscription(ref.read(subscriptionRepositoryProvider))(
        subscriptionId,
      ),
    );
  }

  Future<Subscription> freezeSubscription({
    required String memberId,
    required String subscriptionId,
  }) {
    return _run(
      memberId,
      () => FreezeSubscription(ref.read(subscriptionRepositoryProvider))(
        subscriptionId,
      ),
    );
  }

  /// Runs [action] under the busy flag, refreshing the member's
  /// subscription history after a successful mutation.
  Future<Subscription> _run(
    String memberId,
    Future<Subscription> Function() action,
  ) async {
    state = SubscriptionActionStatus.busy;
    try {
      final subscription = await action();
      ref.invalidate(memberSubscriptionsProvider(memberId));
      return subscription;
    } finally {
      state = SubscriptionActionStatus.idle;
    }
  }
}

/// Tracks whether a subscription mutation is currently running.
final subscriptionControllerProvider =
    NotifierProvider<SubscriptionController, SubscriptionActionStatus>(
      SubscriptionController.new,
    );
