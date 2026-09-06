import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/core/network/supabase_client.dart';
import 'package:gym_management_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gym_management_app/features/auth/domain/entities/app_user.dart';
import 'package:gym_management_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_controller.dart';

/// Resolves the concrete [AuthRepository]. Tests override this provider with
/// an in-memory fake so widget tests never touch Supabase.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(ref.watch(supabaseClientProvider));
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AppUser?>(AuthController.new);
