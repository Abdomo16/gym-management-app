import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Exposes the single, initialized Supabase client.
///
/// Initialization happens once in [AppBootstrap] before `runApp`. Tests
/// override the providers that consume this one, so the client is never
/// touched in widget tests.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
