import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/core/utils/validators.dart';

void main() {
  group('Validators.phone', () {
    // -------------------------------------------------------------------------
    // Empty / null inputs
    // -------------------------------------------------------------------------
    test('null returns an error message', () {
      expect(Validators.phone(null), isNotNull);
    });

    test('empty string returns an error message', () {
      expect(Validators.phone(''), isNotNull);
    });

    test('whitespace-only string returns an error message', () {
      expect(Validators.phone('   '), isNotNull);
    });

    // -------------------------------------------------------------------------
    // Invalid formats
    // -------------------------------------------------------------------------
    test('alphabetic string returns an error message', () {
      expect(Validators.phone('abc'), isNotNull);
    });

    test('alphanumeric string returns an error message', () {
      expect(Validators.phone('phone123'), isNotNull);
    });

    test('too-short number (fewer than 7 digits) returns an error message', () {
      expect(Validators.phone('123456'), isNotNull);
    });

    test('too-long number (more than 15 digits) returns an error message', () {
      // 16 digits — exceeds the 15-digit maximum
      expect(Validators.phone('1234567890123456'), isNotNull);
    });

    // -------------------------------------------------------------------------
    // Valid inputs
    // -------------------------------------------------------------------------
    test('exactly 7 digits is valid', () {
      expect(Validators.phone('1234567'), isNull);
    });

    test('11-digit Egyptian number is valid', () {
      expect(Validators.phone('01012345678'), isNull);
    });

    test('number with country code prefix is valid', () {
      expect(Validators.phone('+201012345678'), isNull);
    });

    test('exactly 15 digits is valid', () {
      expect(Validators.phone('123456789012345'), isNull);
    });

    // -------------------------------------------------------------------------
    // Normalization before validation
    // -------------------------------------------------------------------------
    test('number with spaces is valid after normalization', () {
      // '010 1234 5678' normalizes to '01012345678' (11 digits) → valid
      expect(Validators.phone('010 1234 5678'), isNull);
    });

    test('number with dashes is valid after normalization', () {
      expect(Validators.phone('010-1234-5678'), isNull);
    });

    test('number with country code and dashes is valid after normalization', () {
      expect(Validators.phone('+20-10-1234-5678'), isNull);
    });

    test('number with surrounding whitespace is valid after normalization', () {
      expect(Validators.phone('  01012345678  '), isNull);
    });

    // -------------------------------------------------------------------------
    // Error message content
    // -------------------------------------------------------------------------
    test('default error message is returned for invalid input', () {
      expect(Validators.phone('abc'), 'Enter a valid phone number.');
    });

    test('custom error message is returned when provided', () {
      expect(
        Validators.phone('abc', message: 'Custom phone error.'),
        'Custom phone error.',
      );
    });

    test('required error message is returned for empty input', () {
      // The required check fires before the format check, so the message
      // comes from Validators.required, not the phone message.
      final result = Validators.phone('');
      expect(result, isNotNull);
      expect(result, isNot('Enter a valid phone number.'));
    });
  });
}
