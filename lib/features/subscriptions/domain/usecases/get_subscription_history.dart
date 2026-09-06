import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:gym_management_app/features/subscriptions/domain/repositories/subscription_repository.dart';

/// Loads the full subscription history for one member, newest first.
class GetSubscriptionHistory {
  const GetSubscriptionHistory(this._repository);

  final SubscriptionRepository _repository;

  Future<List<Subscription>> call(String memberId) {
    return _repository.getMemberSubscriptions(memberId);
  }
}
