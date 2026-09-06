import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Data access for `public.subscriptions` and `public.subscription_plans`.
///
/// Every query is tenant-scoped: the current organization is enforced by
/// RLS, and the client never sends an arbitrary organization id. The
/// database computes each subscription's end date from the plan's duration
/// when a subscription is created; the client does not fabricate validity
/// values.
class SubscriptionsRemoteDataSource {
  SubscriptionsRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const String _subscriptionsTable = 'subscriptions';
  static const String _plansTable = 'subscription_plans';

  /// Loads subscription plans for the current organization.
  Future<List<Map<String, dynamic>>> getPlans({bool activeOnly = true}) async {
    var query = _client.from(_plansTable).select();
    if (activeOnly) {
      query = query.eq('is_active', true);
    }
    return _asList(await query.order('name'));
  }

  /// Loads the full subscription history for a member, newest first.
  Future<List<Map<String, dynamic>>> getMemberSubscriptions(
    String memberId,
  ) async {
    final rows = await _client
        .from(_subscriptionsTable)
        .select()
        .eq('member_id', memberId)
        .order('created_at', ascending: false);
    return _asList(rows);
  }

  /// Inserts a subscription. The end date is computed by the database from
  /// the plan's duration; the returned row carries the authoritative period.
  Future<Map<String, dynamic>> createSubscription({
    required String organizationId,
    required String memberId,
    required String planId,
    double? price,
    DateTime? startDate,
  }) async {
    try {
      final plan = await _client
          .from(_plansTable)
          .select('price')
          .eq('id', planId)
          .single();
      final planPrice = (plan['price'] as num?)?.toDouble();
      final resolvedPrice = price ?? planPrice;
      if (resolvedPrice == null) {
        throw const ValidationFailure(
          message: 'The selected subscription plan has no price.',
        );
      }
      final row = await _client
          .from(_subscriptionsTable)
          .insert({
            'organization_id': organizationId,
            'member_id': memberId,
            'plan_id': planId,
            'start_date': _dateOnly(startDate ?? DateTime.now()),
            'price': resolvedPrice,
          })
          .select()
          .single();
      return row;
    } on PostgrestException catch (error) {
      throw _mapPostgrestError(error);
    }
  }

  /// Requests a status transition (freeze/cancel) through the database.
  Future<Map<String, dynamic>> updateSubscriptionStatus({
    required String id,
    required String status,
  }) async {
    try {
      final row = await _client
          .from(_subscriptionsTable)
          .update({'status': status})
          .eq('id', id)
          .select()
          .single();
      return row;
    } on PostgrestException catch (error) {
      throw _mapPostgrestError(error);
    }
  }

  /// Maps PostgREST failures to friendly, non-technical messages.
  AppFailure _mapPostgrestError(PostgrestException error) {
    // 23505 = unique_violation. The approved schema constrains active
    // subscription overlap per member, so this maps to a clear message.
    if (error.code == '23505') {
      return const SupabaseFailure(
        message: 'This member already has an active subscription for that '
            'period.',
      );
    }
    if (error.code == '23514') {
      return const SupabaseFailure(
        message: 'This subscription change is not allowed by the current '
            'business rules.',
      );
    }
    return SupabaseFailure(
      message: 'Unable to save the subscription. Please try again.',
      code: error.code,
      cause: error,
    );
  }

  static List<Map<String, dynamic>> _asList(Object? rows) {
    if (rows is! List) {
      return const [];
    }
    return rows.cast<Map<String, dynamic>>();
  }

  static String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
