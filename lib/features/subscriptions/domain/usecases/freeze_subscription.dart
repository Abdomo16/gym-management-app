import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:gym_management_app/features/subscriptions/domain/repositories/subscription_repository.dart';

/// Requests freezing of a subscription.
///
/// The transition happens through the database; RLS decides whether the
/// caller may perform it. The record itself is never deleted.
class FreezeSubscription {
  const FreezeSubscription(this._repository);

  final SubscriptionRepository _repository;

  Future<Subscription> call(String id) {
    return _repository.updateSubscriptionStatus(
      id: id,
      status: SubscriptionStatus.frozen,
    );
  }
}
