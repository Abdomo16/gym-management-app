import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('required rejects null and blank values', () {
      expect(Validators.required(null), isNotNull);
      expect(Validators.required('   '), isNotNull);
      expect(Validators.required('ok'), isNull);
    });

    test('email accepts valid addresses', () {
      expect(Validators.email('owner@gym.test'), isNull);
      expect(Validators.email('first.last+tag@sub.domain.com'), isNull);
    });

    test('email rejects malformed addresses', () {
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('missing@tld'), isNotNull);
      expect(Validators.email(null), isNotNull);
    });

    test('password enforces minimum length', () {
      expect(Validators.password('short'), isNotNull);
      expect(Validators.password('eightchars'), isNull);
      expect(Validators.password('12345678', minLength: 4), isNull);
    });
  });
}
