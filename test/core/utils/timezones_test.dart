import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/core/utils/timezones.dart';

void main() {
  group('Timezones', () {
    test('derives Africa/Cairo for Egypt offsets', () {
      expect(
        Timezones.defaultForDevice(offset: const Duration(hours: 2)),
        'Africa/Cairo',
      );
      expect(
        Timezones.defaultForDevice(offset: const Duration(hours: 3)),
        'Africa/Cairo',
      );
    });

    test('derives common European defaults', () {
      expect(
        Timezones.defaultForDevice(offset: const Duration(hours: 1)),
        'Europe/London',
      );
      expect(
        Timezones.defaultForDevice(offset: Duration.zero),
        'Europe/London',
      );
    });

    test('derives Gulf and Asia defaults', () {
      expect(
        Timezones.defaultForDevice(offset: const Duration(hours: 4)),
        'Asia/Dubai',
      );
      expect(
        Timezones.defaultForDevice(
          offset: const Duration(hours: 5, minutes: 30),
        ),
        'Asia/Kolkata',
      );
    });

    test('derives US defaults', () {
      expect(
        Timezones.defaultForDevice(offset: const Duration(hours: -5)),
        'America/New_York',
      );
      expect(
        Timezones.defaultForDevice(offset: const Duration(hours: -8)),
        'America/Los_Angeles',
      );
    });

    test('falls back to UTC for unknown offsets', () {
      expect(
        Timezones.defaultForDevice(offset: const Duration(hours: 9)),
        'UTC',
      );
    });

    test('supported list contains the IANA identifiers used by the app', () {
      expect(Timezones.supported, contains('Africa/Cairo'));
      expect(Timezones.supported, contains('America/New_York'));
      expect(Timezones.supported, isNotEmpty);
    });
  });
}
