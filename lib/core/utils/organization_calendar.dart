abstract final class OrganizationCalendar {
  static DateTime businessDate(String timezone, {DateTime? nowUtc}) {
    final utc = (nowUtc ?? DateTime.now()).toUtc();
    final local = utc.add(_offsetFor(timezone, utc));
    return DateTime(local.year, local.month, local.day);
  }

  static Duration _offsetFor(String timezone, DateTime utc) {
    return switch (timezone) {
      'Africa/Cairo' => Duration(hours: _isCairoDaylightTime(utc) ? 3 : 2),
      'Europe/London' => Duration(hours: _isEuropeanDaylightTime(utc) ? 1 : 0),
      'Europe/Berlin' ||
      'Europe/Paris' => Duration(hours: _isEuropeanDaylightTime(utc) ? 2 : 1),
      'Asia/Dubai' => const Duration(hours: 4),
      'Asia/Riyadh' => const Duration(hours: 3),
      'Asia/Kolkata' => const Duration(hours: 5, minutes: 30),
      'America/New_York' => Duration(hours: _isUsDaylightTime(utc) ? -4 : -5),
      'America/Chicago' => Duration(hours: _isUsDaylightTime(utc) ? -5 : -6),
      'America/Los_Angeles' => Duration(
        hours: _isUsDaylightTime(utc) ? -7 : -8,
      ),
      'Australia/Sydney' => Duration(
        hours: _isAustralianDaylightTime(utc) ? 11 : 10,
      ),
      _ => Duration.zero,
    };
  }

  static bool _isCairoDaylightTime(DateTime utc) {
    final year = utc.year;
    final starts = _lastWeekdayOfMonth(year, 4, DateTime.friday);
    final ends = _lastWeekdayOfMonth(year, 10, DateTime.friday);
    final date = DateTime.utc(year, utc.month, utc.day);
    return !date.isBefore(starts) && date.isBefore(ends);
  }

  static bool _isEuropeanDaylightTime(DateTime utc) {
    final year = utc.year;
    final starts = _lastWeekdayOfMonth(year, 3, DateTime.sunday);
    final ends = _lastWeekdayOfMonth(year, 10, DateTime.sunday);
    final date = DateTime.utc(year, utc.month, utc.day);
    return !date.isBefore(starts) && date.isBefore(ends);
  }

  static bool _isUsDaylightTime(DateTime utc) {
    final year = utc.year;
    final starts = _nthWeekdayOfMonth(year, 3, DateTime.sunday, 2);
    final ends = _nthWeekdayOfMonth(year, 11, DateTime.sunday, 1);
    final date = DateTime.utc(year, utc.month, utc.day);
    return !date.isBefore(starts) && date.isBefore(ends);
  }

  static bool _isAustralianDaylightTime(DateTime utc) {
    final year = utc.year;
    final starts = _firstWeekdayOfMonth(year, 10, DateTime.sunday);
    final ends = _firstWeekdayOfMonth(year, 4, DateTime.sunday);
    final date = DateTime.utc(year, utc.month, utc.day);
    if (date.year == year && date.month >= 10) {
      return !date.isBefore(starts);
    }
    if (date.month <= 3) {
      return true;
    }
    return date.month == 4 && date.isBefore(ends);
  }

  static DateTime _lastWeekdayOfMonth(int year, int month, int weekday) {
    var date = DateTime.utc(year, month + 1, 0);
    while (date.weekday != weekday) {
      date = date.subtract(const Duration(days: 1));
    }
    return date;
  }

  static DateTime _firstWeekdayOfMonth(int year, int month, int weekday) {
    var date = DateTime.utc(year, month, 1);
    while (date.weekday != weekday) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  static DateTime _nthWeekdayOfMonth(
    int year,
    int month,
    int weekday,
    int occurrence,
  ) {
    var date = _firstWeekdayOfMonth(year, month, weekday);
    date = date.add(Duration(days: (occurrence - 1) * 7));
    return date;
  }
}
