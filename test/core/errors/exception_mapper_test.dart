import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/core/errors/exception_mapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('ExceptionMapper', () {
    test('maps SocketException to NetworkFailure', () {
      final failure = ExceptionMapper.map(const SocketException('offline'));
      expect(failure, isA<NetworkFailure>());
    });

    test('maps TimeoutException to NetworkFailure', () {
      final failure = ExceptionMapper.map(TimeoutException('slow'));
      expect(failure, isA<NetworkFailure>());
    });

    test('maps Supabase AuthException to AuthFailure', () {
      final failure = ExceptionMapper.map(
        AuthException('Invalid login credentials'),
      );
      expect(failure, isA<AuthFailure>());
      expect(failure.message, 'Invalid login credentials');
    });

    test('maps PostgrestException to SupabaseFailure', () {
      final failure = ExceptionMapper.map(
        PostgrestException(message: 'relation does not exist'),
      );
      expect(failure, isA<SupabaseFailure>());
      expect(failure.message, 'relation does not exist');
    });

    test('maps FormatException to UnexpectedFailure', () {
      final failure = ExceptionMapper.map(const FormatException('bad json'));
      expect(failure, isA<UnexpectedFailure>());
    });

    test('maps unknown errors to UnexpectedFailure', () {
      final failure = ExceptionMapper.map(StateError('boom'));
      expect(failure, isA<UnexpectedFailure>());
    });

    test('passes AppFailure instances through unchanged', () {
      const failure = AuthFailure(message: 'nope');
      expect(identical(ExceptionMapper.map(failure), failure), isTrue);
    });
  });
}
