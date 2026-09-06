import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:gym_management_app/features/members/domain/entities/branch_summary.dart';
import 'package:gym_management_app/features/members/presentation/providers/members_provider.dart';

/// Branches belonging to the authenticated organization, for branch
/// assignment in the member forms.
///
/// The organization id comes from the authenticated profile — never from
/// client input — and the query is additionally scoped server-side by RLS.
final organizationBranchesProvider = FutureProvider<List<BranchSummary>>((
  ref,
) async {
  final organizationId = ref.watch(currentProfileProvider)?.organizationId;
  if (organizationId == null || organizationId.isEmpty) {
    return const [];
  }
  return ref
      .read(membersRepositoryProvider)
      .getOrganizationBranches(organizationId);
});
