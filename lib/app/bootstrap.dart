import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gym_management_app/core/constants/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// One-time application initialization, executed before `runApp`.
abstract final class AppBootstrap {
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: AppConstants.envFileName);
    } on Object {
      throw StateError(
        'Could not load ${AppConstants.envFileName}. Copy .env.example to '
        '.env and fill in your Supabase credentials.',
      );
    }

    final url = dotenv.maybeGet(EnvKeys.supabaseUrl);
    final anonKey = dotenv.maybeGet(EnvKeys.supabaseAnonKey);
    if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
      throw StateError(
        '${EnvKeys.supabaseUrl} and ${EnvKeys.supabaseAnonKey} must be set '
        'in ${AppConstants.envFileName}.',
      );
    }

    // The anon/publishable key is safe for client-side use. Service-role
    // keys must never be embedded in the Flutter application.
    await Supabase.initialize(url: url, publishableKey: anonKey);
  }
}
