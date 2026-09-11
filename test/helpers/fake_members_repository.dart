import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/members/domain/entities/branch_summary.dart';
import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/domain/repositories/members_repository.dart';

/// In-memory [MembersRepository] for unit and controller tests.
///
/// Holds a fixed list of members and exposes flags to simulate failures so
/// tests can exercise error-handling paths without touching Supabase.
class FakeMembersRepository implements MembersRepository {
  FakeMembersRepository({
    List<Member> members = const [],
    this.throwDuplicatePhone = false,
    this.throwOnGet = false,
    this.throwOnDelete = false,
  }) : _members = List<Member>.from(members);

  final List<Member> _members;
  bool throwDuplicatePhone;
  bool throwOnGet;
  bool throwOnDelete;

  /// Read-only view of the stored members for test assertions.
  List<Member> get storedMembers => List.unmodifiable(_members);

  // ---------------------------------------------------------------------------
  // Factory helpers
  // ---------------------------------------------------------------------------

  static Member makeTestMember({
    String id = 'member-1',
    String organizationId = 'org-1',
    String fullName = 'Ahmed Mohamed',
    String phone = '01012345678',
    String? memberCode = 'GYM-000001',
    MemberStatus status = MemberStatus.active,
  }) {
    return Member(
      id: id,
      organizationId: organizationId,
      fullName: fullName,
      phone: phone,
      memberCode: memberCode,
      status: status,
    );
  }

  // ---------------------------------------------------------------------------
  // MembersRepository interface
  // ---------------------------------------------------------------------------

  @override
  Future<List<Member>> getMembers({int limit = 50, int offset = 0}) async {
    if (throwOnGet) {
      throw const SupabaseFailure(message: 'Failed to load members.');
    }
    return _members.skip(offset).take(limit).toList();
  }

  @override
  Future<List<Member>> searchMembers(String query, {int limit = 20}) async {
    if (throwOnGet) {
      throw const SupabaseFailure(message: 'Failed to search members.');
    }
    final q = query.toLowerCase();
    return _members
        .where(
          (m) =>
              m.fullName.toLowerCase().contains(q) ||
              m.phone.contains(q) ||
              (m.memberCode?.toLowerCase().contains(q) ?? false),
        )
        .take(limit)
        .toList();
  }

  @override
  Future<Member?> getMemberById(String id) async {
    if (throwOnGet) {
      throw const SupabaseFailure(message: 'Failed to load member.');
    }
    try {
      return _members.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Member> createMember({
    required String organizationId,
    String? branchId,
    required String fullName,
    required String phone,
    String? gender,
    DateTime? dateOfBirth,
    String? photoUrl,
    String? notes,
  }) async {
    if (throwDuplicatePhone) {
      throw const SupabaseFailure(
        message: 'A member with this phone number already exists.',
      );
    }
    final member = makeTestMember(
      organizationId: organizationId,
      fullName: fullName,
      phone: phone,
    );
    _members.add(member);
    return member;
  }

  @override
  Future<Member> updateMember({
    required String id,
    String? branchId,
    required String fullName,
    required String phone,
    String? gender,
    DateTime? dateOfBirth,
    String? photoUrl,
    String? notes,
  }) async {
    final index = _members.indexWhere((m) => m.id == id);
    final base = index >= 0 ? _members[index] : makeTestMember(id: id);
    final updated = base.copyWith(
      fullName: fullName,
      phone: phone,
      branchId: branchId,
      gender: gender != null ? MemberGenderX.fromWireName(gender) : base.gender,
      dateOfBirth: dateOfBirth ?? base.dateOfBirth,
      photoUrl: photoUrl ?? base.photoUrl,
      notes: notes ?? base.notes,
    );
    if (index >= 0) {
      _members[index] = updated;
    }
    return updated;
  }

  @override
  Future<Member> updateMemberStatus({
    required String id,
    required MemberStatus status,
  }) async {
    final index = _members.indexWhere((m) => m.id == id);
    final base = index >= 0 ? _members[index] : makeTestMember(id: id);
    final updated = base.copyWith(status: status);
    if (index >= 0) {
      _members[index] = updated;
    }
    return updated;
  }

  @override
  Future<void> deleteMember(String id) async {
    if (throwOnDelete) {
      throw const SupabaseFailure(
        message: 'Only the gym owner or a manager can delete members.',
      );
    }
    _members.removeWhere((m) => m.id == id);
  }

  @override
  Future<List<BranchSummary>> getOrganizationBranches(
    String organizationId,
  ) async {
    return const [BranchSummary(id: 'branch-1', name: 'Main Branch')];
  }
}
