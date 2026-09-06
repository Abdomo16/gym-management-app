/// IANA timezone support for organization onboarding.
abstract final class Timezones {
  /// Curated list of common IANA timezone identifiers shown in onboarding.
  static const List<String> supported = [
    'Africa/Cairo',
    'Europe/London',
    'Europe/Berlin',
    'Europe/Paris',
    'Asia/Dubai',
    'Asia/Riyadh',
    'Asia/Kolkata',
    'America/New_York',
    'America/Chicago',
    'America/Los_Angeles',
    'Australia/Sydney',
  ];

  /// Derives a sensible IANA default from the device's UTC offset.
  ///
  /// [offset] is injectable for tests; defaults to the device timezone.
  static String defaultForDevice({Duration? offset}) {
    final localOffset = offset ?? DateTime.now().timeZoneOffset;
    return switch (localOffset) {
      const Duration(hours: 2) || const Duration(hours: 3) => 'Africa/Cairo',
      const Duration(hours: 1) || const Duration() => 'Europe/London',
      const Duration(hours: 4) => 'Asia/Dubai',
      const Duration(hours: 5, minutes: 30) => 'Asia/Kolkata',
      const Duration(hours: -5) || const Duration(hours: -4) =>
        'America/New_York',
      const Duration(hours: -8) || const Duration(hours: -7) =>
        'America/Los_Angeles',
      _ => 'UTC',
    };
  }
}
