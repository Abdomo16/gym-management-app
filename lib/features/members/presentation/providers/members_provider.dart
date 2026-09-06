import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/core/network/supabase_client.dart';
import 'package:gym_management_app/features/members/data/datasources/members_remote_datasource.dart';
import 'package:gym_management_app/features/members/data/repositories/members_repository_impl.dart';
import 'package:gym_management_app/features/members/domain/repositories/members_repository.dart';

/// Resolves the concrete [MembersRepository]. Tests override this provider
/// with an in-memory fake so widget tests never touch Supabase.
final membersRepositoryProvider = Provider<MembersRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseMembersRepository(MembersRemoteDataSource(client));
});
