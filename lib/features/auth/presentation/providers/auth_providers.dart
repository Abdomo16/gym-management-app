import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/core/network/supabase_client.dart';
import 'package:gym_management_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:gym_management_app/features/auth/data/datasources/profile_remote_datasource.dart';
import 'package:gym_management_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gym_management_app/features/auth/domain/entities/auth_state.dart';
import 'package:gym_management_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_controller.dart';

/// Resolves the concrete [AuthRepository]. Tests override this provider with
/// an in-memory fake so widget tests never touch Supabase.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseAuthRepository(
    authDataSource: AuthRemoteDataSource(client),
    profileDataSource: ProfileRemoteDataSource(client),
  );
});

/// The application's auth state. The router guard and derived providers
/// consume this.
final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
