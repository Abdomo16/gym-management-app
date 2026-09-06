import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/core/utils/phone_normalizer.dart';

void main() {
  group('PhoneNormalizer.normalize', () {
    test('null returns empty string', () {
      expect(PhoneNormalizer.normalize(null), '');
    });

    test('empty string returns empty string', () {
      expect(PhoneNormalizer.normalize(''), '');
    });

    test('whitespace-only string returns empty string', () {
      expect(PhoneNormalizer.normalize('   '), '');
    });

    test('plain digits are returned unchanged', () {
      expect(PhoneNormalizer.normalize('01012345678'), '01012345678');
    });

    test('strips spaces between digits', () {
      expect(PhoneNormalizer.normalize('010 1234 5678'), '01012345678');
    });

    test('strips dashes between digits', () {
      expect(PhoneNormalizer.normalize('010-1234-5678'), '01012345678');
    });

    test('strips dots between digits', () {
      expect(PhoneNormalizer.normalize('010.1234.5678'), '01012345678');
    });

    test('strips parentheses', () {
      expect(PhoneNormalizer.normalize('(010)12345678'), '01012345678');
    });

    test('strips slashes', () {
      expect(PhoneNormalizer.normalize('010/12345678'), '01012345678');
    });

    test('preserves leading + (country code marker)', () {
      expect(PhoneNormalizer.normalize('+201012345678'), '+201012345678');
    });

    test('preserves leading + and strips dashes', () {
      expect(PhoneNormalizer.normalize('+20-10-1234-5678'), '+201012345678');
    });

    test('preserves leading + and strips spaces', () {
      expect(PhoneNormalizer.normalize('+20 10 1234 5678'), '+201012345678');
    });

    test('trims surrounding whitespace before normalizing', () {
      expect(PhoneNormalizer.normalize('  01012345678  '), '01012345678');
    });

    test('trims whitespace and preserves leading +', () {
      expect(PhoneNormalizer.normalize('  +201012345678  '), '+201012345678');
    });

    test('mixed formatting characters are all stripped', () {
      expect(PhoneNormalizer.normalize('+20 (10) 123-45.678'), '+201012345678');
    });

    test('non-digit non-plus characters in the middle are stripped', () {
      expect(PhoneNormalizer.normalize('0101.234-5678'), '01012345678');
    });
  });
}
