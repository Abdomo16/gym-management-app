import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';

/// Maps a `public.subscriptions` row (PostgREST map) into the
/// [Subscription] entity.
abstract final class SubscriptionMapper {
  static Subscription fromMap(Map<String, dynamic> map) {
    final status = SubscriptionStatusX.fromWireName(map['status'] as String?);
    if (status == null) {
      throw const ValidationFailure(
        message: 'A subscription has an unsupported status. Please contact '
            'your gym administrator.',
      );
    }
    final startDate = _parseDate(map['start_date']);
    if (startDate == null) {
      throw const ValidationFailure(
        message: 'A subscription is missing its start date. Please contact '
            'your gym administrator.',
      );
    }
    return Subscription(
      id: map['id'] as String,
      organizationId: map['organization_id'] as String,
      memberId: map['member_id'] as String,
      planId: map['plan_id'] as String,
      startDate: startDate,
      endDate: _parseDate(map['end_date']),
      price: (map['price'] as num?)?.toDouble(),
      paymentStatus: map['payment_status'] as String?,
      createdBy: map['created_by'] as String?,
      status: status,
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
