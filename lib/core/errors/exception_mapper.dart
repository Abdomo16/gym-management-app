import 'dart:async';
import 'dart:io';

import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Maps arbitrary thrown objects into typed [AppFailure]s.
///
/// Every repository boundary should funnel thrown exceptions through
/// [ExceptionMapper.map] so the rest of the app only ever handles
/// [AppFailure] subtypes.
abstract final class ExceptionMapper {
  static AppFailure map(Object error) {
    return switch (error) {
      // Already mapped failures pass through untouched.
      AppFailure() => error,
      // Auth (gotrue) errors.
      AuthException() => AuthFailure(
        message: _friendlyAuthMessage(error),
        code: error.code,
        cause: error,
      ),
      // PostgREST / database errors.
      PostgrestException() => SupabaseFailure(
        message: error.message,
        code: error.code,
        cause: error,
      ),
      // Transport layer errors.
      SocketException() => NetworkFailure(cause: error),
      TimeoutException() => NetworkFailure(
        message: 'The request timed out. Please try again.',
        cause: error,
      ),
      // Malformed payloads.
      FormatException() => const UnexpectedFailure(
        message: 'The server returned an unexpected response.',
      ),
      // Anything else: keep the cause for debuggability but surface a
      // user-friendly message.
      _ => UnexpectedFailure(
        message: 'Something went wrong. Please try again.',
        cause: error,
      ),
    };
  }

  /// Maps known Supabase auth error codes to friendly messages.
  ///
  /// Deliberately does not distinguish "email not registered" from "wrong
  /// password" to avoid account enumeration.
  static String _friendlyAuthMessage(AuthException error) {
    return switch (error.code) {
      'invalid_credentials' => 'Invalid email or password.',
      'email_not_confirmed' => 'Please verify your email before signing in.',
      'weak_password' => 'The password is too weak.',
      'over_request_rate_limit' =>
        'Too many attempts. Please try again in a moment.',
      _ => 'Unable to sign in. Please try again.',
    };
  }
}
