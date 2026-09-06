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
        message: error.message,
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
      // Anything else: keep the message for debuggability.
      _ => UnexpectedFailure(
        message: error.toString(),
        cause: error,
      ),
    };
  }
}
