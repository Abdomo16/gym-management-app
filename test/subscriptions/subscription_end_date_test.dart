import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/features/subscriptions/data/datasources/subscriptions_remote_datasource.dart';

void main() {
  group('SubscriptionsRemoteDataSource.computeSubscriptionEndDate', () {
    test('a 30-day plan covers start day through day 30', () {
      final start = DateTime(2026, 9, 11);
      final end = SubscriptionsRemoteDataSource.computeSubscriptionEndDate(
        start,
        30,
      );
      expect(end, DateTime(2026, 10, 10));
    });

    test('a 1-day plan ends on the start day itself', () {
      final start = DateTime(2026, 9, 11);
      final end = SubscriptionsRemoteDataSource.computeSubscriptionEndDate(
        start,
        1,
      );
      expect(end, start);
    });

    test('a 360-day plan spans just under a full year', () {
      final start = DateTime(2026, 1, 1);
      final end = SubscriptionsRemoteDataSource.computeSubscriptionEndDate(
        start,
        360,
      );
      expect(end, DateTime(2026, 12, 26));
    });

    test('crosses month and year boundaries correctly', () {
      final start = DateTime(2026, 12, 20);
      final end = SubscriptionsRemoteDataSource.computeSubscriptionEndDate(
        start,
        30,
      );
      expect(end, DateTime(2027, 1, 18));
    });
  });
}
