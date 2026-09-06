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

    test('maps invalid credentials to a friendly message', () {
      final failure = ExceptionMapper.map(
        const AuthException('Invalid login credentials', code: 'invalid_credentials'),
      );
      expect(failure, isA<AuthFailure>());
      expect(failure.message, 'Invalid email or password.');
    });

    test('maps unconfirmed email to a friendly message', () {
      final failure = ExceptionMapper.map(
        const AuthException('Email not confirmed', code: 'email_not_confirmed'),
      );
      expect(failure, isA<AuthFailure>());
      expect(failure.message, 'Please verify your email before signing in.');
    });

    test('does not leak unknown auth error details', () {
      final failure = ExceptionMapper.map(
        const AuthException('some internal detail'),
      );
      expect(failure, isA<AuthFailure>());
      expect(failure.message, 'Unable to sign in. Please try again.');
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

    test('maps unknown errors to a friendly UnexpectedFailure', () {
      final failure = ExceptionMapper.map(StateError('boom'));
      expect(failure, isA<UnexpectedFailure>());
      expect(failure.message, 'Something went wrong. Please try again.');
    });

    test('passes AppFailure instances through unchanged', () {
      const failure = AuthFailure(message: 'nope');
      expect(identical(ExceptionMapper.map(failure), failure), isTrue);
    });
  });
}
