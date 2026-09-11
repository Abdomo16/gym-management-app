import 'package:gym_management_app/features/members/domain/entities/branch_summary.dart';
import 'package:gym_management_app/features/members/domain/entities/member.dart';

/// Contract for member operations.
///
/// Implementations must translate low-level errors into [AppFailure]
/// subtypes before they reach the rest of the application. Every query is
/// tenant-scoped by RLS; the client never selects an organization.
abstract interface class MembersRepository {
  /// Loads the first page of members for the current organization.
  Future<List<Member>> getMembers({int limit = 50});

  /// Searches members by name, phone or member code.
  ///
  /// The search is scoped to the authenticated organization by the database
  /// (RLS); no client-side cross-tenant filtering is involved.
  Future<List<Member>> searchMembers(
    String query, {
    int limit = 20,
  });

  /// Loads a single member, or `null` when not found / not accessible.
  Future<Member?> getMemberById(String id);

  /// Creates a member. [organizationId] must come from the authenticated
  /// tenant context — never from user input. The database generates
  /// `member_code`; the returned [Member] carries it.
  Future<Member> createMember({
    required String organizationId,
    String? branchId,
    required String fullName,
    required String phone,
    String? gender,
    DateTime? dateOfBirth,
    String? photoUrl,
    String? notes,
  });

  /// Updates mutable member fields. `member_code`, `organization_id` and
  /// `id` are never editable.
  Future<Member> updateMember({
    required String id,
    String? branchId,
    required String fullName,
    required String phone,
    String? gender,
    DateTime? dateOfBirth,
    String? photoUrl,
    String? notes,
  });

  /// Changes a member's status (active/inactive/blocked) through the
  /// database; the database/RLS remains the authority for the change.
  Future<Member> updateMemberStatus({
    required String id,
    required MemberStatus status,
  });

  /// Permanently deletes a member and all related records (subscriptions,
  /// attendance, payments, notifications cascade server-side). The
  /// database's RLS delete policy (owner/manager) is the security boundary.
  Future<void> deleteMember(String id);

  /// Branches belonging to the current organization, for branch assignment.
  Future<List<BranchSummary>> getOrganizationBranches(String organizationId);
}
