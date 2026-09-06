import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription_plan.dart';

/// Maps a `public.subscription_plans` row (PostgREST map) into the
/// [SubscriptionPlan] entity.
abstract final class SubscriptionPlanMapper {
  static SubscriptionPlan fromMap(Map<String, dynamic> map) {
    final durationDays = (map['duration_days'] as num?)?.toInt();
    if (durationDays == null) {
      throw const ValidationFailure(
        message: 'A subscription plan is missing its duration. Please '
            'contact your gym administrator.',
      );
    }
    return SubscriptionPlan(
      id: map['id'] as String,
      organizationId: map['organization_id'] as String,
      name: map['name'] as String? ?? 'Unnamed plan',
      description: map['description'] as String?,
      durationDays: durationDays,
      price: (map['price'] as num?)?.toDouble(),
      isActive: map['is_active'] as bool? ?? true,
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
