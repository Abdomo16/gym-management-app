import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:gym_management_app/features/subscriptions/domain/repositories/subscription_repository.dart';

/// Renews a member's subscription by creating a new subscription record.
///
/// Renewal never overwrites or deletes the previous record: history is
/// preserved and the new period starts from [startDate] (defaults to today).
class RenewSubscription {
  const RenewSubscription(this._repository);

  final SubscriptionRepository _repository;

  Future<Subscription> call({
    required String organizationId,
    required String memberId,
    required String planId,
    DateTime? startDate,
  }) {
    return _repository.createSubscription(
      organizationId: organizationId,
      memberId: memberId,
      planId: planId,
      startDate: startDate,
    );
  }
}
