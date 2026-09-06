import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:gym_management_app/features/subscriptions/domain/repositories/subscription_repository.dart';

/// Creates a new subscription for a member.
///
/// [organizationId] must come from the authenticated tenant context, never
/// from user input. The database computes the end date from the plan's
/// duration; no validity value is fabricated client-side.
class CreateSubscription {
  const CreateSubscription(this._repository);

  final SubscriptionRepository _repository;

  Future<Subscription> call({
    required String organizationId,
    required String memberId,
    required String planId,
    double? price,
    DateTime? startDate,
  }) {
    return _repository.createSubscription(
      organizationId: organizationId,
      memberId: memberId,
      planId: planId,
      price: price,
      startDate: startDate,
    );
  }
}
