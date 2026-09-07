import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/core/utils/organization_calendar.dart';

void main() {
  test('uses the organization timezone when deriving the business date', () {
    final businessDate = OrganizationCalendar.businessDate(
      'Africa/Cairo',
      nowUtc: DateTime.utc(2026, 9, 6, 22, 30),
    );

    expect(businessDate, DateTime(2026, 9, 7));
  });

  test('falls back to UTC for an unknown timezone', () {
    final businessDate = OrganizationCalendar.businessDate(
      'UTC',
      nowUtc: DateTime.utc(2026, 9, 6, 23, 30),
    );

    expect(businessDate, DateTime(2026, 9, 6));
  });
}
