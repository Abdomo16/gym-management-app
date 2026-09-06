/// Base class for every failure surfaced by the application.
///
/// Failures are the typed, user-presentable counterpart of raw exceptions:
/// repositories and use cases translate low-level errors into [AppFailure]
/// subtypes via [ExceptionMapper] so UI code never deals with transport
/// details such as sockets or Supabase internals.
sealed class AppFailure implements Exception {
  const AppFailure({
    required this.message,
    this.code,
    this.cause,
  });

  /// Human-readable message safe to show to the end user.
  final String message;

  /// Optional stable error code (e.g. a PostgREST error code).
  final String? code;

  /// The original error that caused this failure, when available.
  final Object? cause;

  @override
  String toString() => '$runtimeType($message)';
}

/// Connectivity problems: offline device, dropped connection, timeouts.
class NetworkFailure extends AppFailure {
  const NetworkFailure({
    super.message = 'You appear to be offline. Check your connection and try again.',
    super.code,
    super.cause,
  });
}

/// The server returned an error response (e.g. 4xx/5xx).
class ServerFailure extends AppFailure {
  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode,
    super.cause,
  });

  final int? statusCode;
}

/// A Supabase operation (database, auth, storage, realtime) failed.
class SupabaseFailure extends AppFailure {
  const SupabaseFailure({
    required super.message,
    super.code,
    super.cause,
  });
}

/// Authentication failed: invalid credentials, expired session, etc.
class AuthFailure extends AppFailure {
  const AuthFailure({
    required super.message,
    super.code,
    super.cause,
  });
}

/// Input failed validation (email format, required field, ...).
class ValidationFailure extends AppFailure {
  const ValidationFailure({
    required super.message,
    super.code,
    super.cause,
  });
}

/// Any error that could not be mapped to a more specific failure type.
class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure({
    required super.message,
    super.code,
    super.cause,
  });
}
