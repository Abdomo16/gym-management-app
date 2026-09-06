/// Application-wide constants.
abstract final class AppConstants {
  static const String appName = 'GymFlow';
  static const String appVersion = '1.0.0';
  static const String envFileName = '.env';
}

/// Keys for environment variables read from `.env`.
///
/// Secrets must never be hardcoded. The Supabase anon/publishable key is safe
/// to embed in the client; the service-role key must never ship with the app.
abstract final class EnvKeys {
  static const String supabaseUrl = 'SUPABASE_URL';
  static const String supabaseAnonKey = 'SUPABASE_ANON_KEY';
}
